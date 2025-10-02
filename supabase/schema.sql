-- SyncSphere core schema
-- Run this in Supabase SQL Editor. Adjust as needed.

-- Extensions
create extension if not exists pgcrypto;

-- Users table
create table if not exists public.users (
  id uuid primary key,
  email text,
  role text check (role in ('organizer','attendee','vendor','sponsor')),
  name text,
  inserted_at timestamp with time zone default now()
);

-- Events
create table if not exists public.events (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  date timestamp with time zone,
  description text
);

-- Sessions
create table if not exists public.sessions (
  id uuid primary key default gen_random_uuid(),
  event_id uuid references public.events(id) on delete cascade,
  speaker text,
  start_time timestamp with time zone,
  end_time timestamp with time zone
);

-- Tasks (vendor)
create table if not exists public.tasks (
  id uuid primary key default gen_random_uuid(),
  vendor_id uuid references public.users(id) on delete cascade,
  event_id uuid references public.events(id) on delete cascade,
  status text check (status in ('pending','in_progress','done')) default 'pending',
  deadline timestamp with time zone
);

-- Sponsors
create table if not exists public.sponsors (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  logo_url text,
  contact text
);

-- Sponsor applications
create table if not exists public.sponsor_applications (
  id uuid primary key default gen_random_uuid(),
  sponsor_id uuid references public.sponsors(id) on delete cascade,
  event_id uuid references public.events(id) on delete cascade,
  budget_committed numeric,
  status text check (status in ('pending','approved','rejected')) default 'pending'
);

-- Sponsor ROI
create table if not exists public.sponsor_roi (
  sponsor_id uuid references public.users(id) on delete cascade,
  event_id uuid references public.events(id) on delete cascade,
  booth_visits int default 0,
  clicks int default 0,
  impressions int default 0,
  leads int default 0,
  revenue_generated numeric default 0,
  budget_committed numeric default 0,
  primary key (sponsor_id, event_id)
);

-- Check-ins
create table if not exists public.checkins (
  user_id uuid references public.users(id) on delete cascade,
  event_id uuid references public.events(id) on delete cascade,
  timestamp timestamp with time zone default now(),
  primary key (user_id, event_id, timestamp)
);

-- Feedback
create table if not exists public.feedback (
  id uuid primary key default gen_random_uuid(),
  session_id uuid references public.sessions(id) on delete cascade,
  user_id uuid references public.users(id) on delete cascade,
  rating numeric check (rating >= 1 and rating <= 5),
  comment text,
  timestamp timestamp with time zone default now()
);

-- SOS Alerts
create table if not exists public.sos_alerts (
  alert_id uuid primary key default gen_random_uuid(),
  sender_id uuid references public.users(id) on delete cascade,
  role text,
  event_id uuid references public.events(id) on delete cascade,
  timestamp timestamp with time zone default now(),
  status text check (status in ('active','resolved')) default 'active'
);

-- Announcements
create table if not exists public.announcements (
  id uuid primary key default gen_random_uuid(),
  title text,
  message text,
  timestamp timestamp with time zone default now()
);

-- Gamification
create table if not exists public.gamification (
  user_id uuid primary key references public.users(id) on delete cascade,
  points int default 0,
  badges text[] default '{}'
);

-- Enable RLS
alter table public.users enable row level security;
alter table public.checkins enable row level security;
alter table public.feedback enable row level security;
alter table public.sos_alerts enable row level security;
alter table public.gamification enable row level security;
alter table public.announcements enable row level security;
alter table public.tasks enable row level security;
alter table public.sponsor_roi enable row level security;
alter table public.sponsor_applications enable row level security;
alter table public.sponsors enable row level security;
alter table public.events enable row level security;
alter table public.sessions enable row level security;

-- Basic policies (adjust to your needs)
-- Users: a user can select their own row; organizers can select all
create policy users_self_select on public.users
  for select using (
    auth.uid() = id or exists (select 1 from public.users u where u.id = auth.uid() and u.role = 'organizer')
  );
create policy users_upsert_self on public.users
  for insert with check (auth.uid() = id)
  using (auth.uid() = id);
create policy users_update_self on public.users
  for update using (auth.uid() = id);

-- Checkins: everyone can insert their own; organizers can select all; users select own
create policy checkins_insert_self on public.checkins
  for insert with check (auth.uid() = user_id);
create policy checkins_select_role on public.checkins
  for select using (
    user_id = auth.uid() or exists (select 1 from public.users u where u.id = auth.uid() and u.role = 'organizer')
  );

-- Feedback: users manage their own; organizers can read all
create policy feedback_insert_self on public.feedback for insert with check (auth.uid() = user_id);
create policy feedback_select_role on public.feedback for select using (
  user_id = auth.uid() or exists (select 1 from public.users u where u.id = auth.uid() and u.role = 'organizer')
);

-- SOS alerts: anyone can insert for self; organizers read all
create policy sos_insert_self on public.sos_alerts for insert with check (auth.uid() = sender_id);
create policy sos_select_role on public.sos_alerts for select using (
  sender_id = auth.uid() or exists (select 1 from public.users u where u.id = auth.uid() and u.role = 'organizer')
);

-- Gamification: user reads own; leaderboard is public read (optional)
create policy gamification_select_public on public.gamification for select using (true);
create policy gamification_upsert_self on public.gamification for insert with check (auth.uid() = user_id);
create policy gamification_update_self on public.gamification for update using (auth.uid() = user_id);

-- Announcements: public read; organizers insert
create policy announcements_select_public on public.announcements for select using (true);
create policy announcements_insert_organizer on public.announcements for insert with check (
  exists (select 1 from public.users u where u.id = auth.uid() and u.role = 'organizer')
);

-- Tasks: vendors read own tasks; organizers read all; organizers insert/update
create policy tasks_select_role on public.tasks for select using (
  vendor_id = auth.uid() or exists (select 1 from public.users u where u.id = auth.uid() and u.role = 'organizer')
);
create policy tasks_mutate_organizer on public.tasks for insert with check (
  exists (select 1 from public.users u where u.id = auth.uid() and u.role = 'organizer')
);
create policy tasks_update_vendor_progress on public.tasks for update using (
  vendor_id = auth.uid() or exists (select 1 from public.users u where u.id = auth.uid() and u.role = 'organizer')
);

-- Sponsor ROI: sponsor reads own; organizer reads all
create policy roi_select_role on public.sponsor_roi for select using (
  sponsor_id = auth.uid() or exists (select 1 from public.users u where u.id = auth.uid() and u.role = 'organizer')
);

-- Sponsors and Applications: public read; sponsors insert own applications; organizers update status
create policy sponsors_select_public on public.sponsors for select using (true);
create policy applications_select_role on public.sponsor_applications for select using (true);
create policy applications_insert_sponsor on public.sponsor_applications for insert with check (true);
create policy applications_update_organizer on public.sponsor_applications for update using (
  exists (select 1 from public.users u where u.id = auth.uid() and u.role = 'organizer')
);
