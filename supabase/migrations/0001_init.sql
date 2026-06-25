-- Weatherling — başlangıç şeması + RLS. (Plan §5.3, §16)
-- Supabase SQL Editor'da ya da `supabase db push` ile uygula.

-- Kullanıcı profili (auth.users ile 1:1) ----------------------------
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- Yaratık kaydı (bulut yedek/sync) ----------------------------------
create table if not exists public.creature_saves (
  user_id uuid primary key references auth.users(id) on delete cascade,
  state jsonb not null,
  schema_version int not null default 1,
  updated_at timestamptz default now()
);

-- RLS: herkes SADECE kendi satırını görür/yazar ---------------------
alter table public.profiles enable row level security;
alter table public.creature_saves enable row level security;

drop policy if exists "own_profile" on public.profiles;
create policy "own_profile" on public.profiles
  for all using (auth.uid() = id) with check (auth.uid() = id);

drop policy if exists "own_save" on public.creature_saves;
create policy "own_save" on public.creature_saves
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- Hesap silme RPC (KVKK/GDPR) — kullanıcı kendi auth kaydını siler.
-- creature_saves/profiles cascade ile gider.
create or replace function public.delete_me()
returns void
language sql
security definer
set search_path = public
as $$
  delete from auth.users where id = auth.uid();
$$;

revoke all on function public.delete_me() from public;
grant execute on function public.delete_me() to authenticated;
