# Reobote — Gestão

App interno da **Reobote Sorvetes & Açaí** (Poços de Caldas).
HTML puro + PWA, sem build. Mesma stack do New Wash.

## Arquivos

| arquivo | o que é |
|---|---|
| `index.html` | app de gestão (dono e funcionários) |
| `pedidos.html` | portal do cliente — revenda monta o pedido sozinha |
| `manifest.webmanifest` / `sw.js` | instalação na tela de início + funcionamento offline |
| `assets/` | ícones |

## Acesso

O app **abre direto, sem senha** — a equipe usa o dia todo sem barreira.

A única área trancada é o **Financeiro**, com a senha **2409**.
Uma vez digitada, ela vale até fechar o app; o botão "trancar" fecha antes disso.

Quem está operando é escolhido no ícone de pessoa do topo (sem senha). Serve só para
assinar quem registrou cada produção, perda e leitura de temperatura.

## O que já funciona

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

## Portal de pedidos — o que editar

Abra `pedidos.html` e mexa só no topo do `<script>`:

- `WHATSAPP_FABRICA` — número da fábrica (55 + DDD + número)
- `CATALOGO` — os produtos, preços e unidades de venda

O `id` de cada produto do catálogo **precisa ser o mesmo id da ficha técnica** no app.
Se não bater, o pedido entra mesmo assim, mas sem baixa de estoque.

## Publicar (GitHub Pages)

Mesmo caminho do New Wash: subir a pasta e ativar Pages.
O app vai para `.../reobote/` e o portal para `.../reobote/pedidos.html` — é esse segundo link que vai para os clientes.

## Próximo passo

Hoje os dados ficam **no aparelho** (backup e restauração em Configurações).
Para fábrica, lojas e entregadores verem o mesmo estoque em tempo real, ligar o **Supabase** — a estrutura de dados já foi desenhada pensando nisso.
