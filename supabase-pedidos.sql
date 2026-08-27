-- =====================================================================
-- REOBOTE — pedidos do portal em tempo real
-- Rode uma vez no Supabase:  painel → SQL Editor → cole → Run
-- =====================================================================

create table if not exists reobote_pedidos (
  id          text primary key,
  loja        text not null,
  resp        text,
  tel         text,
  entrega     date,
  obs         text,
  itens       jsonb not null,
  total       numeric not null default 0,
  status      text not null default 'novo',
  criado_em   timestamptz not null default now()
);

create index if not exists reobote_pedidos_criado_idx on reobote_pedidos (criado_em desc);

alter table reobote_pedidos enable row level security;

-- o portal do cliente só precisa criar pedido
drop policy if exists "portal cria pedido" on reobote_pedidos;
create policy "portal cria pedido" on reobote_pedidos
  for insert to anon with check (true);

-- o app da equipe lê e atualiza o andamento
drop policy if exists "app le pedidos" on reobote_pedidos;
create policy "app le pedidos" on reobote_pedidos
  for select to anon using (true);

drop policy if exists "app atualiza pedidos" on reobote_pedidos;
create policy "app atualiza pedidos" on reobote_pedidos
  for update to anon using (true) with check (true);

-- avisa o app no instante em que um pedido entra
alter publication supabase_realtime add table reobote_pedidos;
