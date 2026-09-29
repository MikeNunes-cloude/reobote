-- =====================================================================
-- REOBOTE — pedidos das lojas para a fábrica, em tempo real
-- Rode uma vez no Supabase:  painel → SQL Editor → cole → Run
-- =====================================================================

create table if not exists reobote_solicitacoes (
  id          text primary key,
  unidade     text not null,          -- id da loja que pediu
  unidade_nome text not null,         -- nome, para a fábrica ler sem consultar nada
  quem        text,                   -- quem ditou
  obs         text,
  itens       jsonb not null,         -- [{tipo,ref,nome,qtd,un}]
  status      text not null default 'nova',   -- nova | separando | enviada | recebida | cancelada
  criado_em   timestamptz not null default now(),
  atualizado_em timestamptz not null default now()
);

create index if not exists reobote_solic_criado_idx on reobote_solicitacoes (criado_em desc);

alter table reobote_solicitacoes enable row level security;

-- a loja cria o pedido
drop policy if exists "loja cria solicitacao" on reobote_solicitacoes;
create policy "loja cria solicitacao" on reobote_solicitacoes
  for insert to anon with check (true);

-- todo mundo do app lê
drop policy if exists "app le solicitacoes" on reobote_solicitacoes;
create policy "app le solicitacoes" on reobote_solicitacoes
  for select to anon using (true);

-- a fábrica move o andamento (separando, enviada) e a loja confirma
drop policy if exists "app atualiza solicitacoes" on reobote_solicitacoes;
create policy "app atualiza solicitacoes" on reobote_solicitacoes
  for update to anon using (true) with check (true);

-- avisa na hora em que a loja pede
alter publication supabase_realtime add table reobote_solicitacoes;
