-- ============================================================
-- RVIOS Platform — Supabase PostgreSQL Schema
-- Version: 1.0.0
-- Domain: rvios.com | app.rvios.com
-- ============================================================
-- Run this in Supabase SQL Editor (Dashboard → SQL Editor)
-- ============================================================

-- ─────────────────────────────────────────────
-- Extensions
-- ─────────────────────────────────────────────
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ─────────────────────────────────────────────
-- 1. Companies (Tenants)
-- ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.companies (
  id               UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  company_code     TEXT UNIQUE NOT NULL,         -- e.g. CMP-8X7Q2K
  name             TEXT NOT NULL,
  workspace_slug   TEXT UNIQUE NOT NULL,         -- e.g. acme-corp → app.rvios.com/acme-corp
  plan_type        INT  NOT NULL DEFAULT 0,      -- 0=free, 1=pro, 2=business, 3=biz+, 4=enterprise
  subscription_status INT NOT NULL DEFAULT 0,   -- 0=trial, 1=active, 2=suspended, 3=cancelled
  trial_ends_at    TIMESTAMPTZ,
  subscription_ends_at TIMESTAMPTZ,
  owner_id         UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  country          CHAR(2),                      -- ISO 3166-1 alpha-2
  currency         CHAR(3),                      -- ISO 4217
  industry         TEXT,
  expected_employee_count INT,
  logo_url         TEXT,
  website          TEXT,
  phone            TEXT,
  address          TEXT,
  tax_number       TEXT,
  commercial_reg_number TEXT,
  default_language TEXT NOT NULL DEFAULT 'ar',
  default_timezone TEXT NOT NULL DEFAULT 'Asia/Riyadh',
  settings_json    JSONB,
  created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  is_deleted       BOOLEAN NOT NULL DEFAULT FALSE
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_companies_owner_id ON public.companies(owner_id);
CREATE INDEX IF NOT EXISTS idx_companies_workspace_slug ON public.companies(workspace_slug);
CREATE INDEX IF NOT EXISTS idx_companies_plan_type ON public.companies(plan_type);

-- ─────────────────────────────────────────────
-- 2. User Profiles (extends auth.users)
-- ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.user_profiles (
  id                    UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  display_name          TEXT NOT NULL,
  first_name            TEXT,
  last_name             TEXT,
  username              TEXT UNIQUE,
  phone                 TEXT,
  account_type          INT NOT NULL DEFAULT 0,   -- 0=free_personal, 1=pro, 2=business, 3=enterprise
  active_company_id     UUID REFERENCES public.companies(id),
  employee_code         TEXT,
  workspace_slug        TEXT,
  avatar_url            TEXT,
  language              TEXT NOT NULL DEFAULT 'ar',
  timezone              TEXT NOT NULL DEFAULT 'Asia/Riyadh',
  country               CHAR(2),
  onboarding_completed  BOOLEAN NOT NULL DEFAULT FALSE,
  must_change_password  BOOLEAN NOT NULL DEFAULT FALSE,
  created_at            TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at            TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_user_profiles_username ON public.user_profiles(username);
CREATE INDEX IF NOT EXISTS idx_user_profiles_active_company ON public.user_profiles(active_company_id);

-- Auto-create profile on user signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.user_profiles (id, display_name)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1))
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ─────────────────────────────────────────────
-- 3. Company Members (User ↔ Company junction)
-- ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.company_members (
  id                   UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  company_id           UUID NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
  user_id              UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  employee_id          UUID,                      -- FK to employees table (if exists)
  role                 INT NOT NULL DEFAULT 8,    -- 0=owner, 1=super_admin ... 8=employee, 9=guest
  is_active            BOOLEAN NOT NULL DEFAULT TRUE,
  joined_at            TIMESTAMPTZ,
  onboarding_completed BOOLEAN NOT NULL DEFAULT FALSE,
  permissions_json     JSONB,
  enabled_modules      TEXT[],                    -- override company defaults
  created_at           TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at           TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  is_deleted           BOOLEAN NOT NULL DEFAULT FALSE,
  UNIQUE(company_id, user_id)
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_company_members_company ON public.company_members(company_id);
CREATE INDEX IF NOT EXISTS idx_company_members_user ON public.company_members(user_id);
CREATE INDEX IF NOT EXISTS idx_company_members_role ON public.company_members(role);

-- ─────────────────────────────────────────────
-- 4. Invitations
-- ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.invitations (
  id                     UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  company_id             UUID NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
  invited_by             UUID NOT NULL REFERENCES auth.users(id),
  token                  UUID UNIQUE NOT NULL DEFAULT uuid_generate_v4(),
  email                  TEXT,
  pre_assigned_username  TEXT,
  temp_password_hash     TEXT,                    -- bcrypt hash
  employee_code          TEXT,                    -- e.g. EMP-00215
  role                   INT NOT NULL DEFAULT 8,
  department_id          UUID,
  position_id            UUID,
  status                 INT NOT NULL DEFAULT 0,  -- 0=pending, 1=accepted, 2=expired, 3=cancelled
  expires_at             TIMESTAMPTZ NOT NULL,
  used_at                TIMESTAMPTZ,
  resulting_user_id      UUID REFERENCES auth.users(id),
  created_at             TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at             TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  is_deleted             BOOLEAN NOT NULL DEFAULT FALSE
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_invitations_company ON public.invitations(company_id);
CREATE INDEX IF NOT EXISTS idx_invitations_token ON public.invitations(token);
CREATE INDEX IF NOT EXISTS idx_invitations_status ON public.invitations(status);
CREATE INDEX IF NOT EXISTS idx_invitations_email ON public.invitations(email) WHERE email IS NOT NULL;

-- ─────────────────────────────────────────────
-- 5. Audit Logs
-- ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.audit_logs (
  id             UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  actor_id       UUID NOT NULL REFERENCES auth.users(id),
  company_id     UUID NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
  action         TEXT NOT NULL,                  -- e.g. "invoice.created"
  entity_type    TEXT,                           -- e.g. "invoice"
  entity_id      UUID,                           -- sync_id of the affected record
  description    TEXT,
  old_value      JSONB,
  new_value      JSONB,
  ip_address     INET,
  device_info    TEXT,
  platform       TEXT,
  severity       INT NOT NULL DEFAULT 0,         -- 0=info, 1=warning, 2=critical
  created_at     TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes (partitioned by time for performance at scale)
CREATE INDEX IF NOT EXISTS idx_audit_logs_company ON public.audit_logs(company_id);
CREATE INDEX IF NOT EXISTS idx_audit_logs_actor ON public.audit_logs(actor_id);
CREATE INDEX IF NOT EXISTS idx_audit_logs_created ON public.audit_logs(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_audit_logs_action ON public.audit_logs(action);

-- ─────────────────────────────────────────────
-- Updated_at auto-update trigger
-- ─────────────────────────────────────────────
CREATE OR REPLACE FUNCTION public.set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply to all tables
DO $$
DECLARE
  t TEXT;
BEGIN
  FOR t IN SELECT unnest(ARRAY[
    'companies', 'user_profiles', 'company_members', 'invitations'
  ])
  LOOP
    EXECUTE format('
      DROP TRIGGER IF EXISTS trg_set_updated_at ON public.%I;
      CREATE TRIGGER trg_set_updated_at
        BEFORE UPDATE ON public.%I
        FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
    ', t, t);
  END LOOP;
END $$;

-- ============================================================
-- Row Level Security (RLS) Policies
-- ============================================================

-- ─────────────────────────────────────────────
-- Companies RLS
-- ─────────────────────────────────────────────
ALTER TABLE public.companies ENABLE ROW LEVEL SECURITY;

-- Owner and members can view their company
CREATE POLICY "companies_select" ON public.companies
  FOR SELECT USING (
    owner_id = auth.uid()
    OR id IN (
      SELECT company_id FROM public.company_members
      WHERE user_id = auth.uid() AND is_active = TRUE AND is_deleted = FALSE
    )
  );

-- Only owner can update company info
CREATE POLICY "companies_update" ON public.companies
  FOR UPDATE USING (owner_id = auth.uid());

-- Any authenticated user can create a company
CREATE POLICY "companies_insert" ON public.companies
  FOR INSERT WITH CHECK (owner_id = auth.uid());

-- ─────────────────────────────────────────────
-- User Profiles RLS
-- ─────────────────────────────────────────────
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;

-- Users can view their own profile
CREATE POLICY "user_profiles_select_own" ON public.user_profiles
  FOR SELECT USING (id = auth.uid());

-- Company admins can view profiles of their members
CREATE POLICY "user_profiles_select_members" ON public.user_profiles
  FOR SELECT USING (
    id IN (
      SELECT user_id FROM public.company_members
      WHERE company_id IN (
        SELECT company_id FROM public.company_members
        WHERE user_id = auth.uid() AND role <= 2 AND is_active = TRUE
      )
    )
  );

-- Users can update their own profile
CREATE POLICY "user_profiles_update" ON public.user_profiles
  FOR UPDATE USING (id = auth.uid());

-- ─────────────────────────────────────────────
-- Company Members RLS
-- ─────────────────────────────────────────────
ALTER TABLE public.company_members ENABLE ROW LEVEL SECURITY;

-- Members can see other members of their company
CREATE POLICY "company_members_select" ON public.company_members
  FOR SELECT USING (
    company_id IN (
      SELECT company_id FROM public.company_members
      WHERE user_id = auth.uid() AND is_active = TRUE AND is_deleted = FALSE
    )
  );

-- Admins can add/remove members
CREATE POLICY "company_members_insert" ON public.company_members
  FOR INSERT WITH CHECK (
    company_id IN (
      SELECT company_id FROM public.company_members
      WHERE user_id = auth.uid() AND role <= 2 AND is_active = TRUE
    )
  );

CREATE POLICY "company_members_update" ON public.company_members
  FOR UPDATE USING (
    company_id IN (
      SELECT company_id FROM public.company_members
      WHERE user_id = auth.uid() AND role <= 2 AND is_active = TRUE
    )
  );

-- ─────────────────────────────────────────────
-- Invitations RLS
-- ─────────────────────────────────────────────
ALTER TABLE public.invitations ENABLE ROW LEVEL SECURITY;

-- Admins can view company invitations
CREATE POLICY "invitations_select" ON public.invitations
  FOR SELECT USING (
    company_id IN (
      SELECT company_id FROM public.company_members
      WHERE user_id = auth.uid() AND role <= 2 AND is_active = TRUE
    )
    -- OR token lookup (for redemption, handled by function)
  );

-- Admins can create invitations
CREATE POLICY "invitations_insert" ON public.invitations
  FOR INSERT WITH CHECK (
    company_id IN (
      SELECT company_id FROM public.company_members
      WHERE user_id = auth.uid() AND role <= 2 AND is_active = TRUE
    )
  );

-- ─────────────────────────────────────────────
-- Audit Logs RLS
-- ─────────────────────────────────────────────
ALTER TABLE public.audit_logs ENABLE ROW LEVEL SECURITY;

-- Only admins can view audit logs
CREATE POLICY "audit_logs_select" ON public.audit_logs
  FOR SELECT USING (
    company_id IN (
      SELECT company_id FROM public.company_members
      WHERE user_id = auth.uid() AND role <= 1 AND is_active = TRUE
    )
  );

-- System inserts audit logs (service role bypasses RLS)
CREATE POLICY "audit_logs_insert" ON public.audit_logs
  FOR INSERT WITH CHECK (actor_id = auth.uid());

-- ============================================================
-- Helper Functions
-- ============================================================

-- Check if a user is a member of a company
CREATE OR REPLACE FUNCTION public.is_member_of(company_uuid UUID)
RETURNS BOOLEAN AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.company_members
    WHERE company_id = company_uuid
      AND user_id = auth.uid()
      AND is_active = TRUE
      AND is_deleted = FALSE
  );
$$ LANGUAGE sql SECURITY DEFINER STABLE;

-- Get the current user's role in a company
CREATE OR REPLACE FUNCTION public.get_member_role(company_uuid UUID)
RETURNS INT AS $$
  SELECT role FROM public.company_members
  WHERE company_id = company_uuid
    AND user_id = auth.uid()
    AND is_active = TRUE
    AND is_deleted = FALSE
  LIMIT 1;
$$ LANGUAGE sql SECURITY DEFINER STABLE;

-- Redeem an invitation by token (called from client with service key)
CREATE OR REPLACE FUNCTION public.redeem_invitation(invitation_token UUID)
RETURNS JSONB AS $$
DECLARE
  inv public.invitations%ROWTYPE;
BEGIN
  SELECT * INTO inv FROM public.invitations
  WHERE token = invitation_token
    AND status = 0
    AND expires_at > NOW()
    AND is_deleted = FALSE
  FOR UPDATE;

  IF NOT FOUND THEN
    RETURN jsonb_build_object('success', false, 'error', 'invalid_or_expired');
  END IF;

  -- Mark as accepted
  UPDATE public.invitations SET
    status = 1,
    used_at = NOW(),
    resulting_user_id = auth.uid(),
    updated_at = NOW()
  WHERE token = invitation_token;

  -- Create membership
  INSERT INTO public.company_members (company_id, user_id, role, joined_at, onboarding_completed)
  VALUES (inv.company_id, auth.uid(), inv.role, NOW(), FALSE)
  ON CONFLICT (company_id, user_id) DO UPDATE
    SET is_active = TRUE, role = inv.role, joined_at = NOW(), updated_at = NOW();

  RETURN jsonb_build_object(
    'success', true,
    'company_id', inv.company_id,
    'role', inv.role
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
