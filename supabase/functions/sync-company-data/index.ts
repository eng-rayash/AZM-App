// Supabase Edge Function: sync-company-data  
// Endpoint: POST /functions/v1/sync-company-data
//
// Handles bidirectional sync between client's local Drift DB and Supabase.
// Called when the app comes online after offline period.
//
// Flow:
//   1. Client sends local_changes (records modified while offline)
//   2. Server applies changes and returns server_changes (since last_sync_at)
//   3. Client merges server_changes into local DB

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.3";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

interface SyncPayload {
  company_sync_id: string;
  user_id: string;
  last_sync_at: string;       // ISO timestamp of last successful sync
  local_changes: LocalChange[];
}

interface LocalChange {
  table: string;              // e.g. "tasks", "meetings"
  operation: "insert" | "update" | "delete";
  record_id: string;
  data: Record<string, unknown>;
  changed_at: string;         // ISO timestamp
}

serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    // Use user's JWT for RLS enforcement
    const authHeader = req.headers.get("Authorization") ?? "";
    
    const supabase = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_ANON_KEY") ?? "",
      { global: { headers: { Authorization: authHeader } } }
    );

    const payload: SyncPayload = await req.json();
    const { company_sync_id, user_id, last_sync_at, local_changes } = payload;

    const syncErrors: string[] = [];
    let appliedCount = 0;

    // ── 1. Apply local changes to Supabase ─────────────────────
    for (const change of local_changes) {
      try {
        if (change.operation === "delete") {
          await supabase
            .from(change.table)
            .delete()
            .eq("id", change.record_id)
            .eq("company_sync_id", company_sync_id);
        } else {
          await supabase
            .from(change.table)
            .upsert({
              ...change.data,
              company_sync_id,
              updated_at: change.changed_at,
            });
        }
        appliedCount++;
      } catch (err) {
        syncErrors.push(`${change.table}:${change.record_id} - ${err}`);
      }
    }

    // ── 2. Fetch server changes since last_sync_at ──────────────
    // In production, each table would be queried for changes.
    // For now, return metadata so client knows sync completed.
    const serverChangesAt = new Date().toISOString();

    // ── 3. Log sync event ────────────────────────────────────────
    await supabase.from("rvios_audit_logs").insert({
      company_sync_id,
      action: "data_sync",
      entity_type: "sync",
      entity_id: user_id,
      performed_by: user_id,
      meta: {
        local_changes_count: local_changes.length,
        applied_count: appliedCount,
        errors: syncErrors,
      },
    });

    return new Response(
      JSON.stringify({
        success: true,
        applied_count: appliedCount,
        errors: syncErrors,
        server_sync_at: serverChangesAt,
        server_changes: [],   // TODO: implement delta fetch per table
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
