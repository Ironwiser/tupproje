-- FIRETRACK Supabase şeması
-- Supabase Dashboard > SQL Editor içinde çalıştırın.

create extension if not exists "pgcrypto";

-- Şirketler (kurumsal hesaplar)
create table if not exists public.companies (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  owner_id uuid not null references auth.users (id) on delete cascade,
  created_at timestamptz not null default now()
);

-- Kullanıcı profilleri
create table if not exists public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  full_name text,
  user_type text not null default 'individual' check (user_type in ('individual', 'corporate')),
  company_id uuid references public.companies (id) on delete set null,
  is_premium boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Yangın tüpleri
create table if not exists public.fire_extinguishers (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  company_id uuid references public.companies (id) on delete cascade,
  name text not null,
  type text not null,
  brand text not null,
  purchase_date date not null,
  expiry_date date not null,
  location text not null,
  serial_number text,
  notes text,
  photo_url text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists idx_fire_extinguishers_user_id on public.fire_extinguishers (user_id);
create index if not exists idx_fire_extinguishers_company_id on public.fire_extinguishers (company_id);

-- RLS
alter table public.companies enable row level security;
alter table public.profiles enable row level security;
alter table public.fire_extinguishers enable row level security;

-- Profiller
drop policy if exists "profiles_select_own" on public.profiles;
create policy "profiles_select_own"
  on public.profiles for select
  using (auth.uid() = id);

drop policy if exists "profiles_insert_own" on public.profiles;
create policy "profiles_insert_own"
  on public.profiles for insert
  with check (auth.uid() = id);

drop policy if exists "profiles_update_own" on public.profiles;
create policy "profiles_update_own"
  on public.profiles for update
  using (auth.uid() = id);

-- Şirketler
drop policy if exists "companies_select_own" on public.companies;
create policy "companies_select_own"
  on public.companies for select
  using (auth.uid() = owner_id);

drop policy if exists "companies_insert_own" on public.companies;
create policy "companies_insert_own"
  on public.companies for insert
  with check (auth.uid() = owner_id);

drop policy if exists "companies_update_own" on public.companies;
create policy "companies_update_own"
  on public.companies for update
  using (auth.uid() = owner_id);

-- Tüpler: bireysel (company_id null) veya kendi şirketi
drop policy if exists "extinguishers_select" on public.fire_extinguishers;
create policy "extinguishers_select"
  on public.fire_extinguishers for select
  using (
    auth.uid() = user_id
    or (
      company_id is not null
      and company_id in (
        select company_id from public.profiles where id = auth.uid()
      )
    )
  );

drop policy if exists "extinguishers_insert" on public.fire_extinguishers;
create policy "extinguishers_insert"
  on public.fire_extinguishers for insert
  with check (auth.uid() = user_id);

drop policy if exists "extinguishers_update" on public.fire_extinguishers;
create policy "extinguishers_update"
  on public.fire_extinguishers for update
  using (auth.uid() = user_id);

drop policy if exists "extinguishers_delete" on public.fire_extinguishers;
create policy "extinguishers_delete"
  on public.fire_extinguishers for delete
  using (auth.uid() = user_id);

-- Storage bucket (Dashboard > Storage > New bucket: extinguisher-photos, public: false)
-- Aşağıdaki politikalar bucket oluşturduktan sonra çalıştırılmalı:

-- create policy "photo_upload_own"
--   on storage.objects for insert
--   with check (
--     bucket_id = 'extinguisher-photos'
--     and auth.uid()::text = (storage.foldername(name))[1]
--   );
--
-- create policy "photo_read_own"
--   on storage.objects for select
--   using (
--     bucket_id = 'extinguisher-photos'
--     and auth.uid()::text = (storage.foldername(name))[1]
--   );

-- Yeni kullanıcı kaydında boş profil oluştur
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.profiles (id, full_name)
  values (new.id, coalesce(new.raw_user_meta_data->>'full_name', 'Kullanıcı'))
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();
