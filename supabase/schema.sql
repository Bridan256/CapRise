-- CapRise manual payment approval schema.
-- Apply this in the Supabase SQL editor for project cptlygpmhshrvluhhgss.

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  phone text not null,
  role text not null default 'user' check (role in ('user', 'admin')),
  created_at timestamptz not null default now()
);

create table if not exists public.payment_requests (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  package_name text not null,
  amount numeric(14,2) not null check (amount > 0),
  provider text not null check (provider in ('MTN Mobile Money', 'Airtel Money')),
  payment_phone text not null,
  provider_reference text not null unique,
  status text not null default 'pending' check (status in ('pending', 'approved', 'rejected')),
  submitted_at timestamptz not null default now(),
  reviewed_at timestamptz,
  reviewed_by uuid references auth.users(id),
  rejection_reason text
);

create table if not exists public.withdrawal_requests (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  amount numeric(14,2) not null check (amount > 0),
  phone text not null,
  status text not null default 'pending' check (status in ('pending', 'approved', 'rejected')),
  requested_at timestamptz not null default now(),
  reviewed_at timestamptz,
  reviewed_by uuid references auth.users(id),
  rejection_reason text
);

create or replace function public.is_admin()
returns boolean
language sql
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.profiles
    where id = auth.uid() and role = 'admin'
  );
$$;

alter table public.profiles enable row level security;
alter table public.payment_requests enable row level security;
alter table public.withdrawal_requests enable row level security;

create policy "Users can read own profile" on public.profiles
  for select using (id = auth.uid() or public.is_admin());

create policy "Users can read own payments" on public.payment_requests
  for select using (user_id = auth.uid() or public.is_admin());

create policy "Users can submit own payments" on public.payment_requests
  for insert with check (user_id = auth.uid());

create policy "Admins can review payments" on public.payment_requests
  for update using (public.is_admin()) with check (public.is_admin());

create policy "Users can read own withdrawals" on public.withdrawal_requests
  for select using (user_id = auth.uid() or public.is_admin());

create policy "Users can submit own withdrawals" on public.withdrawal_requests
  for insert with check (user_id = auth.uid());

create policy "Admins can review withdrawals" on public.withdrawal_requests
  for update using (public.is_admin()) with check (public.is_admin());

create index if not exists payment_requests_status_idx on public.payment_requests(status);
create index if not exists payment_requests_user_idx on public.payment_requests(user_id);
create index if not exists withdrawal_requests_status_idx on public.withdrawal_requests(status);
create index if not exists withdrawal_requests_user_idx on public.withdrawal_requests(user_id);
