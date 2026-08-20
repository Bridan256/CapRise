-- CapRise manual payment approval schema.
-- Apply this in the Supabase SQL editor for project cptlygpmhshrvluhhgss.

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  phone text not null,
  username text,
  referred_by uuid references public.profiles(id),
  role text not null default 'user' check (role in ('user', 'admin')),
  created_at timestamptz not null default now()
);

alter table public.profiles add column if not exists username text;
alter table public.profiles add column if not exists referred_by uuid references public.profiles(id);

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

create policy "Users can read their referrals" on public.profiles
  for select using (referred_by = auth.uid());

create policy "Users can create own profile" on public.profiles
  for insert with check (id = auth.uid());

create policy "Users can update own profile" on public.profiles
  for update using (id = auth.uid()) with check (id = auth.uid());

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

create table if not exists public.investment_packages (
  name text primary key,
  investment numeric(14,2) not null check (investment > 0),
  daily_income numeric(14,2) not null check (daily_income >= 0)
);

insert into public.investment_packages (name, investment, daily_income) values
  ('Starter', 20000, 2000), ('Bronze', 50000, 8000), ('Silver', 100000, 23000),
  ('Gold', 250000, 26000), ('Platinum', 500000, 50000), ('Diamond', 1000000, 100000),
  ('Elite', 2500000, 160000), ('Premium', 5000000, 500000)
on conflict (name) do update set investment = excluded.investment, daily_income = excluded.daily_income;

create or replace function public.get_wallet_summary()
returns table (invested numeric, daily_income numeric, earned_income numeric, referral_commission numeric, approved_withdrawals numeric, available_balance numeric)
language sql
security definer
set search_path = public
as $$
  with packages as (
    select coalesce(sum(p.amount), 0) as invested,
           coalesce(sum(i.daily_income), 0) as daily_income,
           coalesce(sum(i.daily_income * greatest(0, floor(extract(epoch from (now() - coalesce(p.reviewed_at, p.submitted_at))) / 86400))), 0) as earned_income
    from payment_requests p
    join investment_packages i on i.name = p.package_name
    where p.user_id = auth.uid() and p.status = 'approved'
  ),
  commission as (
    select coalesce(sum(p.amount * 0.05), 0) as referral_commission
    from profiles referred
    join payment_requests p on p.user_id = referred.id and p.status = 'approved'
    where referred.referred_by = auth.uid()
  ),
  withdrawals as (
    select coalesce(sum(amount), 0) as approved_withdrawals
    from withdrawal_requests
    where user_id = auth.uid() and status = 'approved'
  )
  select packages.invested, packages.daily_income, packages.earned_income,
         commission.referral_commission, withdrawals.approved_withdrawals,
         greatest(0, packages.earned_income + commission.referral_commission - withdrawals.approved_withdrawals)
  from packages cross join commission cross join withdrawals;
$$;

create or replace function public.can_request_withdrawal(requested_amount numeric)
returns boolean
language sql
security definer
set search_path = public
as $$
  select s.available_balance >= requested_amount and s.available_balance >= s.invested * 2
  from public.get_wallet_summary() s;
$$;

grant execute on function public.get_wallet_summary() to authenticated;
grant execute on function public.can_request_withdrawal(numeric) to authenticated;

drop policy if exists "Users can submit own withdrawals" on public.withdrawal_requests;
create policy "Users can submit own withdrawals" on public.withdrawal_requests
  for insert with check (user_id = auth.uid() and public.can_request_withdrawal(amount));
