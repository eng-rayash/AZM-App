-- ═══════════════════════════════════════════════════════════════
-- RVIOS Platform — Complete Supabase Schema (All-in-One)
-- Migration: 000_rvios_complete_schema.sql
-- ⚠️  شغّل هذا الملف فقط — تجاهل 001 و 002 تماماً
-- ═══════════════════════════════════════════════════════════════

-- Extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ═══════════════════════════════════════════════════════════════
-- STEP 1: CREATE ALL TABLES FIRST (no policies yet)
-- ═══════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS rvios_companies (
  id                    UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  sync_id               TEXT UNIQUE NOT NULL,
  name                  TEXT NOT NULL,
  plan_type             SMALLINT NOT NULL DEFAULT 0,
  subscription_status   SMALLINT NOT NULL DEFAULT 1,
  max_users             INT NOT NULL DEFAULT 1,
  trial_ends_at         TIMESTAMPTZ,
  subscription_ends_at  TIMESTAMPTZ,
  owner_user_id         TEXT,
  country               TEXT,
  industry              TEXT,
  logo                  TEXT,
  website               TEXT,
  phone                 TEXT,
  address               TEXT,
  tax_number            TEXT,
  commercial_reg_number TEXT,
  default_language      TEXT DEFAULT 'ar',
  default_timezone      TEXT DEFAULT 'Asia/Riyadh',
  settings_json         JSONB,
  is_deleted            BOOLEAN DEFAULT FALSE,
  created_at            TIMESTAMPTZ DEFAULT NOW(),
  updated_at            TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS rvios_company_members (
  id                UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  company_sync_id   TEXT NOT NULL,
  user_supabase_id  TEXT NOT NULL,
  role              SMALLINT DEFAULT 8,
  status            SMALLINT DEFAULT 1,
  display_name      TEXT,
  email             TEXT,
  avatar_url        TEXT,
  joined_at         TIMESTAMPTZ DEFAULT NOW(),
  left_at           TIMESTAMPTZ,
  UNIQUE(company_sync_id, user_supabase_id)
);

CREATE TABLE IF NOT EXISTS rvios_invitations (
  id               UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  company_sync_id  TEXT NOT NULL,
  email            TEXT NOT NULL,
  role             SMALLINT DEFAULT 8,
  invitation_code  TEXT UNIQUE NOT NULL,
  invited_by       TEXT,
  status           SMALLINT DEFAULT 0,
  expires_at       TIMESTAMPTZ,
  accepted_at      TIMESTAMPTZ,
  created_at       TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS rvios_audit_logs (
  id               UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  company_sync_id  TEXT,
  action           TEXT NOT NULL,
  entity_type      TEXT,
  entity_id        TEXT,
  performed_by     TEXT,
  meta             JSONB,
  created_at       TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS rvios_tasks (
  id               UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  sync_id          TEXT UNIQUE NOT NULL,
  company_sync_id  TEXT,
  created_by       UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  assigned_to      TEXT,
  title            TEXT NOT NULL,
  description      TEXT,
  status           SMALLINT DEFAULT 0,
  priority         SMALLINT DEFAULT 2,
  due_date         TIMESTAMPTZ,
  completed_at     TIMESTAMPTZ,
  is_deleted       BOOLEAN DEFAULT FALSE,
  created_at       TIMESTAMPTZ DEFAULT NOW(),
  updated_at       TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS rvios_follow_ups (
  id               UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  sync_id          TEXT UNIQUE NOT NULL,
  company_sync_id  TEXT,
  created_by       UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  assigned_to      TEXT,
  title            TEXT NOT NULL,
  notes            TEXT,
  followup_type    SMALLINT DEFAULT 1,
  entity_type      SMALLINT DEFAULT 1,
  entity_id        BIGINT,
  status           SMALLINT DEFAULT 0,
  priority         SMALLINT DEFAULT 2,
  target_date      DATE,
  completed_at     TIMESTAMPTZ,
  is_deleted       BOOLEAN DEFAULT FALSE,
  created_at       TIMESTAMPTZ DEFAULT NOW(),
  updated_at       TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS rvios_meetings (
  id               UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  sync_id          TEXT UNIQUE NOT NULL,
  company_sync_id  TEXT,
  created_by       UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  title            TEXT NOT NULL,
  notes            TEXT,
  location         TEXT,
  meeting_date     DATE NOT NULL,
  meeting_time     TEXT,
  status           SMALLINT DEFAULT 0,
  meeting_type     SMALLINT DEFAULT 0,
  attendees        TEXT,
  agenda           TEXT,
  minutes          TEXT,
  is_deleted       BOOLEAN DEFAULT FALSE,
  created_at       TIMESTAMPTZ DEFAULT NOW(),
  updated_at       TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS rvios_directives (
  id               UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  sync_id          TEXT UNIQUE NOT NULL,
  company_sync_id  TEXT,
  created_by       UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  title            TEXT NOT NULL,
  body             TEXT,
  directive_type   SMALLINT DEFAULT 0,
  status           SMALLINT DEFAULT 0,
  priority         SMALLINT DEFAULT 2,
  issued_to        TEXT,
  issued_at        DATE,
  due_date         DATE,
  is_deleted       BOOLEAN DEFAULT FALSE,
  created_at       TIMESTAMPTZ DEFAULT NOW(),
  updated_at       TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS rvios_archive (
  id               UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  sync_id          TEXT UNIQUE NOT NULL,
  company_sync_id  TEXT,
  created_by       UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  title            TEXT NOT NULL,
  description      TEXT,
  category         TEXT,
  file_path        TEXT,
  file_name        TEXT,
  file_size        BIGINT,
  mime_type        TEXT,
  archive_date     DATE,
  is_deleted       BOOLEAN DEFAULT FALSE,
  created_at       TIMESTAMPTZ DEFAULT NOW(),
  updated_at       TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS rvios_contacts (
  id               UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  sync_id          TEXT UNIQUE NOT NULL,
  company_sync_id  TEXT,
  created_by       UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  name             TEXT NOT NULL,
  phone            TEXT,
  email            TEXT,
  position         TEXT,
  organization     TEXT,
  category         TEXT,
  notes            TEXT,
  avatar_path      TEXT,
  is_deleted       BOOLEAN DEFAULT FALSE,
  created_at       TIMESTAMPTZ DEFAULT NOW(),
  updated_at       TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS rvios_notes (
  id               UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  sync_id          TEXT UNIQUE NOT NULL,
  company_sync_id  TEXT,
  created_by       UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  title            TEXT NOT NULL,
  content          TEXT,
  color            INTEGER DEFAULT 0,
  is_pinned        BOOLEAN DEFAULT FALSE,
  is_deleted       BOOLEAN DEFAULT FALSE,
  created_at       TIMESTAMPTZ DEFAULT NOW(),
  updated_at       TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS rvios_appointments (
  id               UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  sync_id          TEXT UNIQUE NOT NULL,
  company_sync_id  TEXT,
  created_by       UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  title            TEXT NOT NULL,
  description      TEXT,
  location         TEXT,
  appointment_date DATE NOT NULL,
  start_time       TEXT,
  end_time         TEXT,
  status           SMALLINT DEFAULT 0,
  reminder_minutes INTEGER DEFAULT 30,
  is_deleted       BOOLEAN DEFAULT FALSE,
  created_at       TIMESTAMPTZ DEFAULT NOW(),
  updated_at       TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS rvios_employees (
  id                UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  sync_id           TEXT UNIQUE NOT NULL,
  company_sync_id   TEXT NOT NULL,
  employee_number   TEXT,
  full_name         TEXT NOT NULL,
  email             TEXT,
  phone             TEXT,
  national_id       TEXT,
  position          TEXT,
  department        TEXT,
  branch            TEXT,
  hire_date         DATE,
  end_date          DATE,
  employment_type   SMALLINT DEFAULT 0,
  status            SMALLINT DEFAULT 1,
  basic_salary      DECIMAL(12,2) DEFAULT 0,
  avatar_path       TEXT,
  is_deleted        BOOLEAN DEFAULT FALSE,
  created_at        TIMESTAMPTZ DEFAULT NOW(),
  updated_at        TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS rvios_invoices (
  id               UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  sync_id          TEXT UNIQUE NOT NULL,
  company_sync_id  TEXT NOT NULL,
  invoice_number   TEXT NOT NULL,
  client_name      TEXT,
  client_sync_id   TEXT,
  status           SMALLINT DEFAULT 0,
  subtotal         DECIMAL(12,2) DEFAULT 0,
  tax_amount       DECIMAL(12,2) DEFAULT 0,
  discount_amount  DECIMAL(12,2) DEFAULT 0,
  total            DECIMAL(12,2) DEFAULT 0,
  currency         TEXT DEFAULT 'SAR',
  issue_date       DATE,
  due_date         DATE,
  paid_at          TIMESTAMPTZ,
  notes            TEXT,
  is_deleted       BOOLEAN DEFAULT FALSE,
  created_at       TIMESTAMPTZ DEFAULT NOW(),
  updated_at       TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS rvios_expenses (
  id               UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  sync_id          TEXT UNIQUE NOT NULL,
  company_sync_id  TEXT NOT NULL,
  title            TEXT NOT NULL,
  amount           DECIMAL(12,2) NOT NULL,
  expense_type     SMALLINT DEFAULT 0,
  category         TEXT,
  expense_date     DATE,
  notes            TEXT,
  is_deleted       BOOLEAN DEFAULT FALSE,
  created_at       TIMESTAMPTZ DEFAULT NOW(),
  updated_at       TIMESTAMPTZ DEFAULT NOW()
);

-- ═══════════════════════════════════════════════════════════════
-- STEP 2: ENABLE RLS ON ALL TABLES
-- ═══════════════════════════════════════════════════════════════

ALTER TABLE rvios_companies         ENABLE ROW LEVEL SECURITY;
ALTER TABLE rvios_company_members   ENABLE ROW LEVEL SECURITY;
ALTER TABLE rvios_invitations       ENABLE ROW LEVEL SECURITY;
ALTER TABLE rvios_audit_logs        ENABLE ROW LEVEL SECURITY;
ALTER TABLE rvios_tasks             ENABLE ROW LEVEL SECURITY;
ALTER TABLE rvios_follow_ups        ENABLE ROW LEVEL SECURITY;
ALTER TABLE rvios_meetings          ENABLE ROW LEVEL SECURITY;
ALTER TABLE rvios_directives        ENABLE ROW LEVEL SECURITY;
ALTER TABLE rvios_archive           ENABLE ROW LEVEL SECURITY;
ALTER TABLE rvios_contacts          ENABLE ROW LEVEL SECURITY;
ALTER TABLE rvios_notes             ENABLE ROW LEVEL SECURITY;
ALTER TABLE rvios_appointments      ENABLE ROW LEVEL SECURITY;
ALTER TABLE rvios_employees         ENABLE ROW LEVEL SECURITY;
ALTER TABLE rvios_invoices          ENABLE ROW LEVEL SECURITY;
ALTER TABLE rvios_expenses          ENABLE ROW LEVEL SECURITY;

-- ═══════════════════════════════════════════════════════════════
-- STEP 3: CREATE ALL POLICIES (all tables now exist)
-- ═══════════════════════════════════════════════════════════════

-- Helper function: is user a member of a company?
CREATE OR REPLACE FUNCTION rvios_is_member(company_sid TEXT)
RETURNS BOOLEAN AS $$
  SELECT EXISTS (
    SELECT 1 FROM rvios_company_members
    WHERE company_sync_id = company_sid
      AND user_supabase_id = auth.uid()::TEXT
      AND status = 1
  );
$$ LANGUAGE sql SECURITY DEFINER;

-- Helper function: is user an admin (role <= 2) of a company?
CREATE OR REPLACE FUNCTION rvios_is_admin(company_sid TEXT)
RETURNS BOOLEAN AS $$
  SELECT EXISTS (
    SELECT 1 FROM rvios_company_members
    WHERE company_sync_id = company_sid
      AND user_supabase_id = auth.uid()::TEXT
      AND role <= 2
      AND status = 1
  );
$$ LANGUAGE sql SECURITY DEFINER;

-- Companies: owner or member
CREATE POLICY "companies_select" ON rvios_companies FOR SELECT
  USING (owner_user_id = auth.uid()::TEXT OR rvios_is_member(sync_id));

CREATE POLICY "companies_insert" ON rvios_companies FOR INSERT
  WITH CHECK (owner_user_id = auth.uid()::TEXT);

CREATE POLICY "companies_update" ON rvios_companies FOR UPDATE
  USING (owner_user_id = auth.uid()::TEXT OR rvios_is_admin(sync_id));

-- Company Members
CREATE POLICY "members_select" ON rvios_company_members FOR SELECT
  USING (user_supabase_id = auth.uid()::TEXT OR rvios_is_member(company_sync_id));

CREATE POLICY "members_insert" ON rvios_company_members FOR INSERT
  WITH CHECK (rvios_is_admin(company_sync_id) OR user_supabase_id = auth.uid()::TEXT);

CREATE POLICY "members_update" ON rvios_company_members FOR UPDATE
  USING (rvios_is_admin(company_sync_id));

-- Invitations
CREATE POLICY "invitations_select" ON rvios_invitations FOR SELECT
  USING (rvios_is_member(company_sync_id) OR email = auth.email());

CREATE POLICY "invitations_insert" ON rvios_invitations FOR INSERT
  WITH CHECK (rvios_is_admin(company_sync_id));

-- Audit Logs
CREATE POLICY "audit_select" ON rvios_audit_logs FOR SELECT
  USING (company_sync_id IS NULL OR rvios_is_admin(company_sync_id));

CREATE POLICY "audit_insert" ON rvios_audit_logs FOR INSERT
  WITH CHECK (company_sync_id IS NULL OR rvios_is_member(company_sync_id));

-- Tasks
CREATE POLICY "tasks_select" ON rvios_tasks FOR SELECT
  USING (created_by = auth.uid() OR company_sync_id IS NULL OR rvios_is_member(company_sync_id));

CREATE POLICY "tasks_insert" ON rvios_tasks FOR INSERT
  WITH CHECK (created_by = auth.uid() OR rvios_is_member(company_sync_id));

CREATE POLICY "tasks_update" ON rvios_tasks FOR UPDATE
  USING (created_by = auth.uid() OR rvios_is_member(company_sync_id));

-- Follow Ups
CREATE POLICY "followups_all" ON rvios_follow_ups
  USING (created_by = auth.uid() OR company_sync_id IS NULL OR rvios_is_member(company_sync_id));

-- Meetings
CREATE POLICY "meetings_all" ON rvios_meetings
  USING (created_by = auth.uid() OR company_sync_id IS NULL OR rvios_is_member(company_sync_id));

-- Directives
CREATE POLICY "directives_all" ON rvios_directives
  USING (created_by = auth.uid() OR company_sync_id IS NULL OR rvios_is_member(company_sync_id));

-- Archive
CREATE POLICY "archive_all" ON rvios_archive
  USING (created_by = auth.uid() OR company_sync_id IS NULL OR rvios_is_member(company_sync_id));

-- Contacts
CREATE POLICY "contacts_all" ON rvios_contacts
  USING (created_by = auth.uid() OR company_sync_id IS NULL OR rvios_is_member(company_sync_id));

-- Notes
CREATE POLICY "notes_all" ON rvios_notes
  USING (created_by = auth.uid() OR company_sync_id IS NULL OR rvios_is_member(company_sync_id));

-- Appointments
CREATE POLICY "appointments_all" ON rvios_appointments
  USING (created_by = auth.uid() OR company_sync_id IS NULL OR rvios_is_member(company_sync_id));

-- Employees
CREATE POLICY "employees_all" ON rvios_employees
  USING (rvios_is_member(company_sync_id));

-- Invoices
CREATE POLICY "invoices_all" ON rvios_invoices
  USING (rvios_is_member(company_sync_id));

-- Expenses
CREATE POLICY "expenses_all" ON rvios_expenses
  USING (rvios_is_member(company_sync_id));

-- ═══════════════════════════════════════════════════════════════
-- STEP 4: UPDATED_AT TRIGGER
-- ═══════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DO $$
DECLARE t TEXT;
BEGIN
  FOREACH t IN ARRAY ARRAY[
    'rvios_companies', 'rvios_tasks', 'rvios_follow_ups',
    'rvios_meetings', 'rvios_directives', 'rvios_archive',
    'rvios_contacts', 'rvios_notes', 'rvios_appointments',
    'rvios_employees', 'rvios_invoices', 'rvios_expenses'
  ] LOOP
    EXECUTE format(
      'DROP TRIGGER IF EXISTS trg_%s_updated ON %s;
       CREATE TRIGGER trg_%s_updated
       BEFORE UPDATE ON %s
       FOR EACH ROW EXECUTE FUNCTION update_updated_at_column()',
      replace(t,'rvios_',''), t,
      replace(t,'rvios_',''), t
    );
  END LOOP;
END; $$;

-- ═══════════════════════════════════════════════════════════════
-- STEP 5: REALTIME
-- ═══════════════════════════════════════════════════════════════

ALTER PUBLICATION supabase_realtime ADD TABLE rvios_tasks;
ALTER PUBLICATION supabase_realtime ADD TABLE rvios_follow_ups;
ALTER PUBLICATION supabase_realtime ADD TABLE rvios_meetings;
ALTER PUBLICATION supabase_realtime ADD TABLE rvios_company_members;
ALTER PUBLICATION supabase_realtime ADD TABLE rvios_appointments;

-- ═══════════════════════════════════════════════════════════════
-- Done ✓
-- ═══════════════════════════════════════════════════════════════
SELECT 
  'RVIOS Schema Created Successfully ✓' AS status,
  COUNT(*) AS rvios_tables
FROM information_schema.tables 
WHERE table_schema = 'public' 
  AND table_name LIKE 'rvios_%';
