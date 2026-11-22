-- On Music — banco de dados no Supabase
-- Cole tudo no SQL Editor do Supabase e clique em "Run".

-- Faixas enviadas pelos artistas locais
create table if not exists faixas (
  id bigint generated always as identity primary key,
  created_at timestamptz default now(),
  titulo text not null,
  artista text not null,
  email text not null,
  genero text,
  audio_url text not null,
  declaracao_direitos boolean not null check (declaracao_direitos),
  aceite_termos boolean not null check (aceite_termos),
  status text not null default 'publicada' check (status in ('publicada','oculta'))
);

-- Denúncias de faixas
create table if not exists denuncias (
  id bigint generated always as identity primary key,
  created_at timestamptz default now(),
  faixa_id bigint references faixas(id) on delete cascade,
  motivo text
);

-- Episódios do Oncast (cadastrados por você no painel)
create table if not exists episodios (
  id bigint generated always as identity primary key,
  titulo text not null,
  plataforma text default 'Instagram',   -- Instagram ou Facebook
  data date not null default current_date,
  duracao text,                           -- ex.: 24 min
  audio_url text not null,                -- link do áudio (ex.: arquivo no bucket "oncast")
  link text,                              -- link do post no Instagram/Facebook
  ativo boolean default true
);

-- Agenda de eventos
create table if not exists eventos (
  id bigint generated always as identity primary key,
  data date not null,
  hora text,
  titulo text not null,
  local text,
  categoria text default 'Cultura'
);

-- Anúncios e promoções
create table if not exists anuncios (
  id bigint generated always as identity primary key,
  tipo text default 'Destaque',          -- Destaque, Cupom, Patrocínio do podcast...
  empresa text not null,
  oferta text,
  cupom text,
  cor text default '#33d6ef',
  ordem int default 0,
  ativo boolean default true
);

-- Enquetes e votos
create table if not exists enquetes (
  id bigint generated always as identity primary key,
  created_at timestamptz default now(),
  pergunta text not null,
  opcoes text[] not null,
  ativa boolean default true
);
create table if not exists enquete_votos (
  id bigint generated always as identity primary key,
  created_at timestamptz default now(),
  enquete_id bigint references enquetes(id) on delete cascade,
  opcao int not null
);

-- Pedidos de anunciantes e sugestões de evento
create table if not exists pedidos_anuncio (
  id bigint generated always as identity primary key,
  created_at timestamptz default now(),
  empresa text, responsavel text, contato text, tipo text
);
create table if not exists sugestoes_evento (
  id bigint generated always as identity primary key,
  created_at timestamptz default now(),
  titulo text, data_local text
);

-- Segurança (RLS): o público só lê o que está ativo e só insere o que o app permite.
alter table faixas enable row level security;
alter table denuncias enable row level security;
alter table episodios enable row level security;
alter table eventos enable row level security;
alter table anuncios enable row level security;
alter table enquetes enable row level security;
alter table enquete_votos enable row level security;
alter table pedidos_anuncio enable row level security;
alter table sugestoes_evento enable row level security;

create policy "ler faixas publicadas" on faixas for select using (status = 'publicada');
create policy "artista publica faixa" on faixas for insert with check (status = 'publicada' and declaracao_direitos and aceite_termos);
create policy "enviar denuncia" on denuncias for insert with check (true);
create policy "ler episodios" on episodios for select using (ativo);
create policy "ler eventos" on eventos for select using (true);
create policy "ler anuncios" on anuncios for select using (ativo);
create policy "ler enquetes" on enquetes for select using (ativa);
create policy "ler votos" on enquete_votos for select using (true);
create policy "votar" on enquete_votos for insert with check (true);
create policy "pedir anuncio" on pedidos_anuncio for insert with check (true);
create policy "sugerir evento" on sugestoes_evento for insert with check (true);

-- Armazenamento dos áudios
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('musicas', 'musicas', true, 15728640, array['audio/mpeg','audio/mp4','audio/x-m4a','audio/aac','audio/wav','audio/x-wav','audio/ogg','audio/webm'])
on conflict (id) do nothing;
insert into storage.buckets (id, name, public)
values ('oncast', 'oncast', true)
on conflict (id) do nothing;

create policy "enviar musica" on storage.objects for insert with check (bucket_id = 'musicas');
create policy "ouvir audios" on storage.objects for select using (bucket_id in ('musicas','oncast'));

-- Conteúdo inicial de exemplo (apague ou edite à vontade)
insert into enquetes (pergunta, opcoes) values
 ('Que tipo de música você mais ouve?', array['Sertanejo','Rock','Pop','Gospel','Rap']);

-- ============================================================
-- ADMINISTRADORES
-- Só quem estiver na tabela "admins" pode editar e publicar.
-- ============================================================
create table if not exists admins (
  user_id uuid primary key references auth.users(id) on delete cascade,
  email text
);
alter table admins enable row level security;

create or replace function is_admin() returns boolean
language sql stable security definer set search_path = public as $$
  select exists (select 1 from admins where user_id = auth.uid());
$$;
grant execute on function is_admin() to anon, authenticated;

create policy "admin le admins" on admins for select using (is_admin());

-- Acesso total do administrador a todo o conteúdo
create policy "admin faixas" on faixas for all using (is_admin()) with check (is_admin());
create policy "admin denuncias" on denuncias for all using (is_admin()) with check (is_admin());
create policy "admin episodios" on episodios for all using (is_admin()) with check (is_admin());
create policy "admin eventos" on eventos for all using (is_admin()) with check (is_admin());
create policy "admin anuncios" on anuncios for all using (is_admin()) with check (is_admin());
create policy "admin enquetes" on enquetes for all using (is_admin()) with check (is_admin());
create policy "admin votos" on enquete_votos for all using (is_admin()) with check (is_admin());
create policy "admin pedidos" on pedidos_anuncio for all using (is_admin()) with check (is_admin());
create policy "admin sugestoes" on sugestoes_evento for all using (is_admin()) with check (is_admin());

-- Áudios: o administrador envia episódios do Oncast e pode apagar qualquer áudio
create policy "admin audios" on storage.objects for all
  using (bucket_id in ('musicas','oncast') and is_admin())
  with check (bucket_id in ('musicas','oncast') and is_admin());

-- Para tornar alguém administrador (depois de criar o usuário em Authentication → Users):
-- insert into admins (user_id, email) select id, email from auth.users where email = 'SEU-EMAIL-AQUI';
