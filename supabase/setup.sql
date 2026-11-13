-- =====================================================================
-- NOSSAFLIX: configuração do Supabase
-- Cole tudo no Supabase → SQL Editor → New query → Run.
-- Pode rodar mais de uma vez sem problema.
-- =====================================================================

-- 1) Tabela de dados do app
--    key = 'content'        → títulos, episódios, perfis, configurações
--    key = 'user:<perfil>'  → minha lista, avaliações e progresso de cada perfil
create table if not exists public.kv (
  key        text primary key,
  value      jsonb not null,
  updated_at timestamptz not null default now()
);

alter table public.kv enable row level security;

drop policy if exists "kv: logados leem"    on public.kv;
drop policy if exists "kv: logados criam"   on public.kv;
drop policy if exists "kv: logados editam"  on public.kv;
drop policy if exists "kv: logados apagam"  on public.kv;

create policy "kv: logados leem"   on public.kv for select to authenticated using (true);
create policy "kv: logados criam"  on public.kv for insert to authenticated with check (true);
create policy "kv: logados editam" on public.kv for update to authenticated using (true) with check (true);
create policy "kv: logados apagam" on public.kv for delete to authenticated using (true);

-- 2) Bucket PRIVADO para fotos e vídeos
insert into storage.buckets (id, name, public)
values ('media', 'media', false)
on conflict (id) do update set public = false;

drop policy if exists "media: logados leem"   on storage.objects;
drop policy if exists "media: logados enviam" on storage.objects;
drop policy if exists "media: logados trocam" on storage.objects;
drop policy if exists "media: logados apagam" on storage.objects;

create policy "media: logados leem"   on storage.objects for select to authenticated using (bucket_id = 'media');
create policy "media: logados enviam" on storage.objects for insert to authenticated with check (bucket_id = 'media');
create policy "media: logados trocam" on storage.objects for update to authenticated using (bucket_id = 'media') with check (bucket_id = 'media');
create policy "media: logados apagam" on storage.objects for delete to authenticated using (bucket_id = 'media');

-- Pronto! Agora, no painel:
--  • Authentication → Sign In / Providers → desligue "Allow new users to sign up"
--  • Authentication → Users → Add user → Create new user (marque "Auto Confirm User")
--    crie o login de vocês (pode ser uma conta só do casal).
