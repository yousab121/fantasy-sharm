-- فانتزي شرم الشيخ — شغّل الملف ده كامل في Supabase → SQL Editor

-- لاعيبة (حسابات حقيقية + ديمو)
create table if not exists public.players (
  id uuid primary key default gen_random_uuid(),
  user_id uuid unique references auth.users(id) on delete cascade,
  name text not null,
  age int check (age is null or (age >= 10 and age <= 60)),
  pos text not null check (pos in ('G','D','M','F')) default 'M',
  club_id int not null default 0 check (club_id >= 0 and club_id <= 7),
  rating int not null default 60 check (rating >= 40 and rating <= 99),
  points int not null default 0,
  photo_url text,
  approved boolean not null default false,
  is_admin boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- فرق الفانتزي لكل مستخدم
create table if not exists public.squads (
  user_id uuid primary key references auth.users(id) on delete cascade,
  team_name text not null default 'فريقي',
  player_ids uuid[] not null default '{}',
  captain_id uuid references public.players(id) on delete set null,
  total_points int not null default 0,
  updated_at timestamptz not null default now()
);

-- إعدادات عامة (جولة، إلخ)
create table if not exists public.app_settings (
  id int primary key default 1 check (id = 1),
  gameweek int not null default 1,
  gameweek_label text not null default 'الجولة 1',
  transfers_locked boolean not null default false,
  updated_at timestamptz not null default now()
);

insert into public.app_settings (id) values (1) on conflict (id) do nothing;

-- Storage للصور
insert into storage.buckets (id, name, public)
values ('avatars', 'avatars', true)
on conflict (id) do nothing;

-- RLS
alter table public.players enable row level security;
alter table public.squads enable row level security;
alter table public.app_settings enable row level security;

-- Helpers
create or replace function public.is_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.players p
    where p.user_id = auth.uid() and p.is_admin = true
  );
$$;

-- players policies
drop policy if exists "players_select" on public.players;
create policy "players_select" on public.players
  for select to authenticated, anon
  using (approved = true or user_id = auth.uid() or public.is_admin());

drop policy if exists "players_insert_own" on public.players;
create policy "players_insert_own" on public.players
  for insert to authenticated
  with check (user_id = auth.uid() and is_admin = false);

drop policy if exists "players_update_own" on public.players;
create policy "players_update_own" on public.players
  for update to authenticated
  using (user_id = auth.uid() or public.is_admin())
  with check (
    public.is_admin()
    or (user_id = auth.uid() and is_admin = false)
  );

drop policy if exists "players_delete_admin" on public.players;
create policy "players_delete_admin" on public.players
  for delete to authenticated
  using (public.is_admin());

-- squads policies
drop policy if exists "squads_select" on public.squads;
create policy "squads_select" on public.squads
  for select to authenticated
  using (true);

drop policy if exists "squads_insert_own" on public.squads;
create policy "squads_insert_own" on public.squads
  for insert to authenticated
  with check (user_id = auth.uid());

drop policy if exists "squads_update_own" on public.squads;
create policy "squads_update_own" on public.squads
  for update to authenticated
  using (user_id = auth.uid() or public.is_admin())
  with check (user_id = auth.uid() or public.is_admin());

drop policy if exists "squads_delete_admin" on public.squads;
create policy "squads_delete_admin" on public.squads
  for delete to authenticated
  using (public.is_admin());

-- settings
drop policy if exists "settings_select" on public.app_settings;
create policy "settings_select" on public.app_settings
  for select to authenticated, anon
  using (true);

drop policy if exists "settings_admin" on public.app_settings;
create policy "settings_admin" on public.app_settings
  for update to authenticated
  using (public.is_admin())
  with check (public.is_admin());

-- storage policies
drop policy if exists "avatar_public_read" on storage.objects;
create policy "avatar_public_read" on storage.objects
  for select to public
  using (bucket_id = 'avatars');

drop policy if exists "avatar_upload_own" on storage.objects;
create policy "avatar_upload_own" on storage.objects
  for insert to authenticated
  with check (bucket_id = 'avatars' and (storage.foldername(name))[1] = auth.uid()::text);

drop policy if exists "avatar_update_own" on storage.objects;
create policy "avatar_update_own" on storage.objects
  for update to authenticated
  using (bucket_id = 'avatars' and (storage.foldername(name))[1] = auth.uid()::text);

drop policy if exists "avatar_admin" on storage.objects;
create policy "avatar_admin" on storage.objects
  for all to authenticated
  using (bucket_id = 'avatars' and public.is_admin())
  with check (bucket_id = 'avatars' and public.is_admin());

-- 5 لاعيبة ديمو (معتمدين، من غير حساب دخول)
insert into public.players (id, user_id, name, age, pos, club_id, rating, points, approved, is_admin)
values
  ('11111111-1111-1111-1111-111111111101', null, 'أحمد الجبالي', 24, 'G', 0, 72, 4, true, false),
  ('11111111-1111-1111-1111-111111111102', null, 'محمد عيد', 27, 'D', 1, 75, 6, true, false),
  ('11111111-1111-1111-1111-111111111103', null, 'عمر سالم', 22, 'M', 2, 78, 8, true, false),
  ('11111111-1111-1111-1111-111111111104', null, 'يوسف فرج', 25, 'M', 3, 70, 5, true, false),
  ('11111111-1111-1111-1111-111111111105', null, 'كريم حمدان', 23, 'F', 4, 80, 9, true, false)
on conflict (id) do nothing;
