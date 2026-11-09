-- PULSO MVP - esquema inicial para Supabase / PostgreSQL.
-- Aplicar en un proyecto nuevo tras revisar políticas y requisitos legales.
create extension if not exists pgcrypto;

create table public.countries (
  code char(2) primary key,
  name text not null unique,
  is_active boolean not null default true
);

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  nickname text not null unique,
  country_code char(2) not null references public.countries(code),
  avatar_url text,
  account_status text not null default 'active'
    check (account_status in ('active','suspended','deleted')),
  created_at timestamptz not null default now()
);

create table public.seasons (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  starts_at timestamptz not null,
  ends_at timestamptz not null,
  status text not null default 'scheduled'
    check (status in ('scheduled','active','finished')),
  check (ends_at > starts_at)
);

create table public.missions (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  description text not null,
  category text not null,
  mission_type text not null
    check (mission_type in ('daily','surprise','social','world','special')),
  base_xp integer not null check (base_xp between 0 and 150),
  validation_type text not null default 'self_report'
    check (validation_type in ('answer','self_report','moderator')),
  starts_at timestamptz not null,
  ends_at timestamptz not null,
  status text not null default 'draft'
    check (status in ('draft','scheduled','active','finished','cancelled')),
  created_at timestamptz not null default now(),
  check (ends_at > starts_at)
);

create table public.mission_participations (
  id uuid primary key default gen_random_uuid(),
  mission_id uuid not null references public.missions(id),
  user_id uuid not null references public.profiles(id),
  started_at timestamptz not null default now(),
  completed_at timestamptz,
  validation_status text not null default 'started'
    check (validation_status in ('started','pending','approved','rejected')),
  awarded_xp integer not null default 0 check (awarded_xp >= 0),
  unique (mission_id, user_id)
);

create table public.xp_ledger (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id),
  season_id uuid references public.seasons(id),
  amount integer not null check (amount > 0),
  reason text not null,
  reference_id uuid,
  idempotency_key text not null unique,
  created_at timestamptz not null default now()
);

create index xp_ledger_user_season_idx
  on public.xp_ledger(user_id, season_id);

create table public.world_events (
  id uuid primary key default gen_random_uuid(),
  mission_id uuid not null references public.missions(id),
  global_target integer not null check (global_target > 0),
  starts_at timestamptz not null,
  ends_at timestamptz not null,
  status text not null default 'scheduled'
    check (status in ('scheduled','active','completed','expired')),
  created_at timestamptz not null default now(),
  check (ends_at > starts_at)
);

create table public.world_contributions (
  id uuid primary key default gen_random_uuid(),
  event_id uuid not null references public.world_events(id),
  user_id uuid not null references public.profiles(id),
  country_code char(2) not null references public.countries(code),
  validation_status text not null default 'pending'
    check (validation_status in ('pending','approved','rejected')),
  created_at timestamptz not null default now(),
  unique (event_id, user_id)
);

create table public.sponsors (
  id uuid primary key default gen_random_uuid(),
  business_name text not null,
  country_code char(2) references public.countries(code),
  contact_email text,
  status text not null default 'pending'
    check (status in ('pending','approved','suspended'))
);

create table public.campaigns (
  id uuid primary key default gen_random_uuid(),
  sponsor_id uuid not null references public.sponsors(id),
  mission_id uuid references public.missions(id),
  name text not null,
  starts_at timestamptz not null,
  ends_at timestamptz not null,
  terms_url text,
  status text not null default 'draft'
    check (status in ('draft','active','finished','cancelled')),
  check (ends_at > starts_at)
);

create table public.rewards (
  id uuid primary key default gen_random_uuid(),
  campaign_id uuid not null references public.campaigns(id),
  name text not null,
  reward_type text not null
    check (reward_type in ('badge','coupon','product','experience','draw')),
  stock integer not null default 0 check (stock >= 0),
  expiry_date timestamptz,
  conditions text
);

create table public.reward_redemptions (
  id uuid primary key default gen_random_uuid(),
  reward_id uuid not null references public.rewards(id),
  user_id uuid not null references public.profiles(id),
  unique_code text not null unique,
  status text not null default 'reserved'
    check (status in ('reserved','delivered','redeemed','expired','cancelled')),
  created_at timestamptz not null default now(),
  redeemed_at timestamptz
);

-- Activar RLS antes de conectar una app real.
alter table public.profiles enable row level security;
alter table public.countries enable row level security;
alter table public.seasons enable row level security;
alter table public.missions enable row level security;
alter table public.mission_participations enable row level security;
alter table public.xp_ledger enable row level security;
alter table public.world_events enable row level security;
alter table public.world_contributions enable row level security;
alter table public.sponsors enable row level security;
alter table public.campaigns enable row level security;
alter table public.rewards enable row level security;
alter table public.reward_redemptions enable row level security;

-- Nota: no se añaden políticas permisivas aquí deliberadamente.
-- Antes de producción, crear políticas por rol y operaciones de XP
-- exclusivamente en funciones seguras del servidor.
