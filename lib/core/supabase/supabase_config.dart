/// RVIOS — Supabase Configuration
///
/// Contains the Supabase project URL and public anon key.
/// These are safe to include in client-side code.
///
/// 🔐 The Service Role Key must NEVER be stored here — only in Edge Functions.
library;

class SupabaseConfig {
  SupabaseConfig._();

  /// Supabase Project URL
  static const String url = 'https://psjlycjbaiacdzvtewvi.supabase.co';

  /// Supabase Anon (Public) Key — safe for client-side use
  static const String anonKey =
      'sb_publishable_c1EhUj6faoPYiqy9vPucXg_m7pdb8pQ';

  // ─────────────────────────────────────────────
  // Table Names
  // ─────────────────────────────────────────────

  static const String tableCompanies     = 'rvios_companies';
  static const String tableMembers       = 'rvios_company_members';
  static const String tableInvitations   = 'rvios_invitations';
  static const String tableAuditLogs     = 'rvios_audit_logs';
  static const String tableTasks         = 'rvios_tasks';
  static const String tableMeetings      = 'rvios_meetings';
  static const String tableFollowUps     = 'rvios_follow_ups';
  static const String tableDirectives    = 'rvios_directives';
  static const String tableEmployees     = 'rvios_employees';
  static const String tablePayroll       = 'rvios_payroll';
  static const String tableLeaves        = 'rvios_leaves';
  static const String tableInvoices      = 'rvios_invoices';
  static const String tableExpenses      = 'rvios_expenses';
  static const String tableContacts      = 'rvios_contacts';
  static const String tableNotes         = 'rvios_notes';
  static const String tableAppointments  = 'rvios_appointments';
  static const String tableArchive       = 'rvios_archive';

  // ─────────────────────────────────────────────
  // Realtime Channels
  // ─────────────────────────────────────────────

  static const String channelCompany     = 'company-changes';
  static const String channelTasks       = 'task-changes';
  static const String channelApprovals   = 'approval-changes';
}