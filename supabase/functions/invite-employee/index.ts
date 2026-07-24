// Supabase Edge Function: invite-employee
// Endpoint: POST /functions/v1/invite-employee
//
// Sends a company invitation email via Supabase Auth and stores the invitation
// record in the database. Called from the RVIOS app when an admin invites
// a new member.
//
// Environment variables required:
//   SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY, SMTP_HOST, SMTP_USER, SMTP_PASS

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.3";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

interface InvitePayload {
  company_sync_id: string;
  company_name: string;
  email: string;
  role: number;        // UserRole value
  invited_by_name: string;
  invitation_code: string;
}

serve(async (req: Request) => {
  // Handle CORS preflight
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const supabase = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "",
    );

    const payload: InvitePayload = await req.json();
    const {
      company_sync_id,
      company_name,
      email,
      role,
      invited_by_name,
      invitation_code,
    } = payload;

    // ── 1. Create invitation record in DB ────────────────────────
    const expiresAt = new Date();
    expiresAt.setDate(expiresAt.getDate() + 7); // 7-day expiry

    const { error: dbError } = await supabase
      .from("rvios_invitations")
      .upsert({
        company_sync_id,
        email,
        role,
        invitation_code,
        invited_by: invited_by_name,
        status: 0, // pending
        expires_at: expiresAt.toISOString(),
      });

    if (dbError) {
      throw new Error(`DB error: ${dbError.message}`);
    }

    // ── 2. Send invite email via Supabase Auth ───────────────────
    const inviteUrl = `https://rvios.com/join?code=${invitation_code}`;
    
    const { error: emailError } = await supabase.auth.admin.inviteUserByEmail(
      email,
      {
        redirectTo: inviteUrl,
        data: {
          company_sync_id,
          invitation_code,
          role,
        },
      }
    );

    if (emailError) {
      // Non-fatal: invitation record exists, manual sharing is possible
      console.warn("Email send warning:", emailError.message);
    }

    // ── 3. Log audit event ───────────────────────────────────────
    await supabase.from("rvios_audit_logs").insert({
      company_sync_id,
      action: "member_invited",
      entity_type: "invitation",
      entity_id: invitation_code,
      performed_by: invited_by_name,
      meta: { email, role },
    });

    return new Response(
      JSON.stringify({
        success: true,
        invitation_code,
        expires_at: expiresAt.toISOString(),
        invite_url: inviteUrl,
      }),
      {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
        status: 200,
      }
    );
  } catch (error) {
    return new Response(
      JSON.stringify({ success: false, error: (error as Error).message }),
      {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
        status: 400,
      }
    );
  }
});
