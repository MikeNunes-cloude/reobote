# Reobote — Gestão

App interno da **Reobote Sorvetes & Açaí** (Poços de Caldas).
HTML puro + PWA, sem build. Mesma stack do New Wash.

## Arquivos

| arquivo | o que é |
|---|---|
| `index.html` | app de gestão (dono e funcionários) |
| `pedidos.html` | portal do cliente — revenda monta o pedido sozinha |
| `manifest.webmanifest` / `sw.js` | instalação na tela de início + funcionamento offline |
| `supabase-pedidos.sql` | cria a tabela dos pedidos em tempo real (rodar uma vez) |
| `assets/` | ícones |

## Acesso

O app **abre direto, sem senha e sem perfil** — é da equipe inteira, não do dono.

A única área trancada é o **Financeiro**, com a senha **2409**.
Uma vez digitada, ela vale até fechar o app; o botão "trancar" fecha antes disso.

O que cada aparelho define é a **unidade** onde está (ícone de loja no topo). Todo
registro feito nele entra ou sai daquela unidade.

## Pedidos em tempo real — PASSO OBRIGATÓRIO

O pedido feito no portal aparece no app **na hora**, com som e notificação. Para isso
funcionar, a Reobote precisa do **projeto próprio** no Supabase:

1. No Supabase, **New project** → nome `reobote` (região São Paulo)
2. **SQL Editor** → cole o conteúdo de **`supabase-pedidos.sql`** → **Run**
3. **Settings → API** → copie a *Project URL* e a chave *publishable / anon*
4. Cole os dois valores em `SB_URL` e `SB_KEY`, no topo do `<script>` do
   **`index.html`** e do **`pedidos.html`** (os mesmos dois valores nos dois arquivos)

> Já feito: o projeto da Reobote é o `idrgoyxosahliwihamph` e as credenciais estão
> nos dois arquivos. Este passo só volta a ser necessário se o projeto mudar.

O portal só pode **criar** pedido; apagar não. Para limpar registros de teste, rode no
SQL Editor: `delete from reobote_pedidos where status = 'cancelado';`

**Não reaproveite o projeto de outro cliente.** Essa chave fica visível no código-fonte
de quem abrir a página, então quem tem o link do portal alcança tudo que o projeto
expõe. Um projeto por negócio.

Enquanto isso não for feito, o app avisa em Configurações e o portal manda o pedido
pelo WhatsApp como reserva — o cliente nunca fica sem conseguir pedir.

Depois de criada a tabela, cada celular precisa tocar uma vez em
**Configurações → Ligar notificação neste aparelho** para receber o aviso com som.

Só os pedidos passam pela nuvem. Produção, estoque e financeiro continuam no aparelho.

## Como o negócio está montado no app

**Unidades:** Fábrica · Loja Centro · Loja Zona Sul · Loja São Benedito · Distribuição.
Cada aparelho escolhe em qual unidade está — tudo que for registrado nele entra ou sai dali.

**Freezers:** separados entre os que ficam nas unidades e os **cedidos a clientes**,
espalhados pela cidade e cidades vizinhas. Cada um tem código de patrimônio, onde está,
cidade e temperatura-alvo.

**Clientes:** mercados e padarias, restaurantes, sorveterias e eventos — com cidade,
para dar conta do atendimento fora de Poços.

O app vem **vazio de propósito**: nada de produto ou cliente de exemplo. O primeiro
acesso mostra um guia com os quatro cadastros iniciais.

## O que já funciona

- **Produtos com foto**: cada sabor, taça ou açaí tem foto, preço e (se você quiser) a receita. A foto é comprimida no próprio aparelho — uma foto de 11 MB da câmera vira 70 KB.
- **Receita é opcional**: dá para cadastrar um produto só com nome, foto e preço. Sem receita, o app não baixa insumo sozinho nem calcula custo — e avisa isso em vez de fingir margem de 100%.
- **Ficha técnica → produção**: registra a batelada e o app baixa os insumos sozinho, gera lote, validade e custo real por litro.
- **Rendimento**: compara o produzido com o previsto e avisa quando cai (rendimento baixo = custo subindo sem ninguém ver).
- **Estoque multi-unidade**: fábrica, loja e distribuição separadas, com transferência que só entra depois do **aceite de quem recebe** (e registro de divergência).
- **Cadeia de frio**: leitura de temperatura por freezer, com alerta de "sem leitura hoje" e de fora da faixa.
- **Perdas**: motivo, unidade, responsável e prejuízo em R$ calculado pelo custo real.
- **Validade/FEFO**: baixa sempre pelo lote que vence primeiro e avisa o que está perto de vencer.
- **Custos e margem**: margem por item recalculada quando o preço de um insumo muda; sugere preço para 65% de margem.
- **Lista de compra**: gera o que está abaixo do mínimo e manda pronto no WhatsApp.
- **Pedidos**: novo → separação → rota → entregue, com baixa de estoque na entrega e aviso ao cliente no WhatsApp.
- **Portal do cliente**: a revenda monta o pedido e envia; o link cai no app e vira pedido com 1 toque.
- **Financeiro (senha 2409)**: lucro do período, demonstrativo linha a linha e gráfico dos últimos 6 meses.

### Como o Financeiro calcula

```
  Vendas no balcão      (fechamento de caixa lançado por loja)
+ Pedidos entregues     (revendas e distribuição)
− Custo de produção     (insumo e embalagem das bateladas do período)
− Despesas              (aluguel, energia, salários, impostos...)
− Perdas                (quebra e vencimento, ao custo real)
= Lucro
```

A compra de insumo **não** entra como despesa: ela vira estoque e só pesa no resultado
quando é consumida na produção. Lançar as duas coisas contaria o mesmo gasto duas vezes.

## Logo oficial

O app procura por **`assets/logo.png`**. Se o arquivo existir, ele usa a imagem no topo,
na tela do Financeiro e no portal do cliente. Enquanto não existir, desenha um símbolo
aproximado no lugar.

Para usar o logo de verdade: salve o arquivo como `assets/logo.png` e suba.
Fundo roxo (como o original) fica certo nas duas telas — o topo do app e do portal são roxos.

## Tipografia

A mesma do New Wash: a fonte do próprio sistema (San Francisco no iPhone, Roboto no Android),
em pesos 700/800 com espaçamento fechado. Sem fonte serifada e sem carregar fonte externa —
por isso o app abre instantâneo mesmo com sinal ruim.

## Portal de pedidos — como abastecer

O portal **não tem catálogo escrito à mão**. Ele lê o arquivo `catalogo.json`, que o
próprio app gera:

1. No app: **Mais → Configurações → Gerar catálogo do portal**
2. Baixe o `catalogo.json`
3. Suba o arquivo na mesma pasta do site, ao lado do `pedidos.html`

Entram no catálogo só os produtos com **preço de venda** — o resto é semiacabado e não
se vende avulso. As fotos vão junto. Sem o arquivo, o portal avisa que o catálogo está
em atualização e manda o cliente para o WhatsApp.

A única coisa a editar à mão no `pedidos.html` é o `WHATSAPP_FABRICA`
(55 + DDD + número da fábrica).

## Publicar (GitHub Pages)

Mesmo caminho do New Wash: subir a pasta e ativar Pages.
O app vai para `.../reobote/` e o portal para `.../reobote/pedidos.html` — é esse segundo link que vai para os clientes.

## Próximo passo

Hoje os dados ficam **no aparelho** (backup e restauração em Configurações).
Para fábrica, lojas e entregadores verem o mesmo estoque em tempo real, ligar o **Supabase** — a estrutura de dados já foi desenhada pensando nisso.
