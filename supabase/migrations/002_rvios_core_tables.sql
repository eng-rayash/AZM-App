-- ═══════════════════════════════════════════════════════════════
-- RVIOS Platform — Supabase PostgreSQL Schema
-- Migration: 002_rvios_core_tables.sql
-- 
-- Run this in Supabase Dashboard → SQL Editor
-- Tables: tasks, follow_ups, meetings, directives, archive, contacts
-- ═══════════════════════════════════════════════════════════════

-- ─────────────────────────────────────────────
-- Enable UUID extension
-- ─────────────────────────────────────────────
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ─────────────────────────────────────────────
-- TASKS
-- ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS rvios_tasks (
  id               UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  sync_id          TEXT UNIQUE NOT NULL,
  company_sync_id  TEXT REFERENCES rvios_companies(sync_id) ON DELETE CASCADE,
  created_by       UUID REFERENCES auth.users(id),
  assigned_to      TEXT,
  title            TEXT NOT NULL,
  description      TEXT,
  status           SMALLINT DEFAULT 0,   -- 0=pending,1=in_progress,2=done,3=cancelled
  priority         SMALLINT DEFAULT 2,   -- 0=critical,1=high,2=medium,3=low
  due_date         TIMESTAMPTZ,
  completed_at     TIMESTAMPTZ,
  is_deleted       BOOLEAN DEFAULT FALSE,
  created_at       TIMESTAMPTZ DEFAULT NOW(),
  updated_at       TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE rvios_tasks ENABLE ROW LEVEL SECURITY;

CREATE POLICY "tasks_company_access" ON rvios_tasks
  USING (
    company_sync_id IS NULL OR
    EXISTS (
      SELECT 1 FROM rvios_company_members m
      WHERE m.company_sync_id = rvios_tasks.company_sync_id
        AND m.user_supabase_id = auth.uid()::TEXT
        AND m.status = 1
    )
  );

-- ─────────────────────────────────────────────
-- FOLLOW UPS
-- ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS rvios_follow_ups (
  id               UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  sync_id          TEXT UNIQUE NOT NULL,
  company_sync_id  TEXT REFERENCES rvios_companies(sync_id) ON DELETE CASCADE,
  created_by       UUID REFERENCES auth.users(id),
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

ALTER TABLE rvios_follow_ups ENABLE ROW LEVEL SECURITY;

CREATE POLICY "followups_company_access" ON rvios_follow_ups
  USING (
    company_sync_id IS NULL OR
    EXISTS (
      SELECT 1 FROM rvios_company_members m
      WHERE m.company_sync_id = rvios_follow_ups.company_sync_id
        AND m.user_supabase_id = auth.uid()::TEXT
        AND m.status = 1
    )
  );

-- ─────────────────────────────────────────────
-- MEETINGS
-- ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS rvios_meetings (
  id               UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  sync_id          TEXT UNIQUE NOT NULL,
  company_sync_id  TEXT REFERENCES rvios_companies(sync_id) ON DELETE CASCADE,
  created_by       UUID REFERENCES auth.users(id),
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

ALTER TABLE rvios_meetings ENABLE ROW LEVEL SECURITY;

CREATE POLICY "meetings_company_access" ON rvios_meetings
  USING (
    company_sync_id IS NULL OR
    EXISTS (
      SELECT 1 FROM rvios_company_members m
      WHERE m.company_sync_id = rvios_meetings.company_sync_id
        AND m.user_supabase_id = auth.uid()::TEXT
        AND m.status = 1
    )
  );

-- ─────────────────────────────────────────────
-- DIRECTIVES (التوجيهات والمعاملات)
-- ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS rvios_directives (
  id               UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  sync_id          TEXT UNIQUE NOT NULL,
  company_sync_id  TEXT REFERENCES rvios_companies(sync_id) ON DELETE CASCADE,
  created_by       UUID REFERENCES auth.users(id),
  title            TEXT NOT NULL,
  body             TEXT,
  directive_type   SMALLINT DEFAULT 0,
  status           SMALLINT DEFAULT 0,
  priority         SMALLINT DEFAULT 2,
  issued_to        TEXT,
  issued_at        DATE,
  due_date         DATE,
  tags             TEXT[],
  is_deleted       BOOLEAN DEFAULT FALSE,
  created_at       TIMESTAMPTZ DEFAULT NOW(),
  updated_at       TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE rvios_directives ENABLE ROW LEVEL SECURITY;

CREATE POLICY "directives_company_access" ON rvios_directives
  USING (
    company_sync_id IS NULL OR
    EXISTS (
      SELECT 1 FROM rvios_company_members m
      WHERE m.company_sync_id = rvios_directives.company_sync_id
        AND m.user_supabase_id = auth.uid()::TEXT
        AND m.status = 1
    )
  );

-- ─────────────────────────────────────────────
-- ARCHIVE
-- ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS rvios_archive (
  id               UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  sync_id          TEXT UNIQUE NOT NULL,
  company_sync_id  TEXT REFERENCES rvios_companies(sync_id) ON DELETE CASCADE,
  created_by       UUID REFERENCES auth.users(id),
  title            TEXT NOT NULL,
  description      TEXT,
  category         TEXT,
  file_path        TEXT,  -- Supabase Storage path
  file_name        TEXT,
  file_size        BIGINT,
  mime_type        TEXT,
  archive_date     DATE,
  tags             TEXT[],
  is_deleted       BOOLEAN DEFAULT FALSE,
  created_at       TIMESTAMPTZ DEFAULT NOW(),
  updated_at       TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE rvios_archive ENABLE ROW LEVEL SECURITY;

CREATE POLICY "archive_company_access" ON rvios_archive
  USING (
    company_sync_id IS NULL OR
    EXISTS (
      SELECT 1 FROM rvios_company_members m
      WHERE m.company_sync_id = rvios_archive.company_sync_id
        AND m.user_supabase_id = auth.uid()::TEXT
        AND m.status = 1
    )
  );

-- ─────────────────────────────────────────────
-- CONTACTS
-- ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS rvios_contacts (
  id               UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  sync_id          TEXT UNIQUE NOT NULL,
  company_sync_id  TEXT REFERENCES rvios_companies(sync_id) ON DELETE CASCADE,
  created_by       UUID REFERENCES auth.users(id),
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

ALTER TABLE rvios_contacts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "contacts_company_access" ON rvios_contacts
  USING (
    company_sync_id IS NULL OR
    EXISTS (
      SELECT 1 FROM rvios_company_members m
      WHERE m.company_sync_id = rvios_contacts.company_sync_id
        AND m.user_supabase_id = auth.uid()::TEXT
        AND m.status = 1
    )
  );

-- ─────────────────────────────────────────────
-- NOTES
-- ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS rvios_notes (
  id               UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  sync_id          TEXT UNIQUE NOT NULL,
  company_sync_id  TEXT REFERENCES rvios_companies(sync_id) ON DELETE CASCADE,
  created_by       UUID REFERENCES auth.users(id),
  title            TEXT NOT NULL,
  content          TEXT,
  color            INTEGER DEFAULT 0,
  is_pinned        BOOLEAN DEFAULT FALSE,
  is_deleted       BOOLEAN DEFAULT FALSE,
  created_at       TIMESTAMPTZ DEFAULT NOW(),
  updated_at       TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE rvios_notes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "notes_company_access" ON rvios_notes
  USING (
    company_sync_id IS NULL OR
    company_sync_id IS NULL AND created_by = auth.uid() OR
    EXISTS (
      SELECT 1 FROM rvios_company_members m
      WHERE m.company_sync_id = rvios_notes.company_sync_id
        AND m.user_supabase_id = auth.uid()::TEXT
        AND m.status = 1
    )
  );

-- ─────────────────────────────────────────────
-- APPOINTMENTS
-- ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS rvios_appointments (
  id               UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  sync_id          TEXT UNIQUE NOT NULL,
  company_sync_id  TEXT REFERENCES rvios_companies(sync_id) ON DELETE CASCADE,
  created_by       UUID REFERENCES auth.users(id),
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

ALTER TABLE rvios_appointments ENABLE ROW LEVEL SECURITY;

CREATE POLICY "appointments_company_access" ON rvios_appointments
  USING (
    company_sync_id IS NULL OR
    EXISTS (
      SELECT 1 FROM rvios_company_members m
      WHERE m.company_sync_id = rvios_appointments.company_sync_id
        AND m.user_supabase_id = auth.uid()::TEXT
        AND m.status = 1
    )
  );

-- ─────────────────────────────────────────────
-- Updated At Triggers
-- ─────────────────────────────────────────────
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DO $$
DECLARE
  t TEXT;
BEGIN
  FOREACH t IN ARRAY ARRAY[
    'rvios_tasks', 'rvios_follow_ups', 'rvios_meetings',
    'rvios_directives', 'rvios_archive', 'rvios_contacts',
    'rvios_notes', 'rvios_appointments'
  ] LOOP
    EXECUTE format(
      'CREATE OR REPLACE TRIGGER trg_%s_updated_at
       BEFORE UPDATE ON %s
       FOR EACH ROW EXECUTE FUNCTION update_updated_at()',
      replace(t, 'rvios_', ''), t
    );
  END LOOP;
END;
$$;

-- ─────────────────────────────────────────────
-- Realtime (enable for live updates)
-- ─────────────────────────────────────────────
ALTER PUBLICATION supabase_realtime ADD TABLE rvios_tasks;
ALTER PUBLICATION supabase_realtime ADD TABLE rvios_follow_ups;
ALTER PUBLICATION supabase_realtime ADD TABLE rvios_meetings;
ALTER PUBLICATION supabase_realtime ADD TABLE rvios_directives;
ALTER PUBLICATION supabase_realtime ADD TABLE rvios_appointments;

-- Done ✓
SELECT 'RVIOS Core Tables Created Successfully' AS status;
