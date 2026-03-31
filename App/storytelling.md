# Storytelling — Performance Comercial
**Metodologia:** Estratégico ao Micro (Visão Geral → Detalhe)
**Público:** Diretores, Gerentes Comerciais e Consultores de Vendas
**Fonte:** ERP Protheus (SQL Server) + Planilha de Metas
**Refresh:** Diário às 06h | **Histórico:** 24 meses

---

## Princípio Narrativo

> "Primeiro mostre o resultado, depois explique o porquê, depois permita o diagnóstico."

O fluxo de navegação segue a pirâmide gerencial:

```
Sheet 01 — Visão Executiva      ← Diretor/Gerente: o que está acontecendo?
Sheet 02 — Performance Comercial ← Gerente/Consultor: quem e onde?
Sheet 03 — Análise de Produtos  ← Analista/Gerente: o que está sendo vendido?
Sheet 04 — Financeiro           ← Financeiro/Diretor: como está a saúde financeira?
```

---

## Sheet 01 — Visão Executiva

**Objetivo:** Responder em segundos: *estamos no caminho certo?*

### Layout sugerido

```
┌─────────────────────────────────────────────────────────────────┐
│  FILTROS GLOBAIS: Período | Região | Consultor                   │
├───────────┬───────────┬───────────┬─────────────────────────────┤
│ Faturamento│   Meta    │ %Atingim. │     Margem de Contribuição  │
│  Realizado │ Faturamento│  de Meta  │          (%)               │
│  R$ XXX   │  R$ XXX   │  XX%      │          XX%               │
│  ▲ YoY    │           │  ████░░   │          ▲ vs mês ant.      │
├───────────┴───────────┴───────────┴─────────────────────────────┤
│                                                                   │
│   FATURAMENTO MoM (Linha + Área)                                  │
│   Eixo X: mês | Eixo Y: R$ | Linha de meta pontilhada           │
│                                                                   │
├─────────────────────────────────────────────────────────────────┤
│  Crescimento MoM (%)    │  Crescimento YoY (%)  │ Qtd Pedidos   │
│  barras +/- por mês     │  comparativo anual     │ COUNT total   │
└─────────────────────────────────────────────────────────────────┘
```

### Objetos Qlik recomendados

| Objeto | Tipo | Dimensão | Medida | Notas |
|---|---|---|---|---|
| KPI Faturamento | KPI Card | — | SUM(Valor_Venda) | Variação YoY em subtítulo |
| KPI Meta | KPI Card | — | SUM(Valor_Meta) | — |
| KPI % Atingimento | KPI Card | — | SUM(Valor_Venda)/SUM(Valor_Meta) | Cor condicional: verde ≥ 100%, amarelo ≥ 80%, vermelho < 80% |
| KPI Margem | KPI Card | — | SUM(Valor_Venda - Custo_Produto)/SUM(Valor_Venda) | Meta: > 30% |
| Gráfico Linha MoM | Line Chart | Ano-Mês | SUM(Valor_Venda), SUM(Valor_Meta) | Dual axis ou reference line |
| Barras MoM % | Bar Chart | Ano-Mês | (Fat. Atual - Fat. Ant.) / Fat. Ant. | Cor +/- |
| KPI Pedidos | KPI Card | — | COUNT(ID_Pedido) | — |

### Set Analysis para MoM e YoY

```qlik
// Faturamento Mês Anterior
SUM({<Ano_Mes = {$(=AddMonths(Max(Ano_Mes),-1))}>} Valor_Venda)

// Faturamento Ano Anterior (mesmo mês)
SUM({<Ano = {$(=Max(Ano)-1)}>} Valor_Venda)

// % Atingimento de Meta
SUM(Valor_Venda) / SUM({<Fonte_Meta={'META'}>} Valor_Meta)
```

---

## Sheet 02 — Performance Comercial

**Objetivo:** Identificar *quem* e *onde* estão os melhores e piores desempenhos.

### Layout sugerido

```
┌─────────────────────────────────────────────────────────────────┐
│  FILTROS: Período | UF | Gerência Regional | Consultor           │
├─────────────────────────────────┬───────────────────────────────┤
│  FATURAMENTO POR REGIÃO/UF      │  RANKING DE CONSULTORES        │
│  (Mapa do Brasil ou Treemap)    │  Barras horizontais ordenadas  │
│  Cor: intensidade do faturamento│  Valor_Venda + % Atingimento   │
│                                 │                               │
├─────────────────────────────────┴───────────────────────────────┤
│  % ATINGIMENTO DE META POR CONSULTOR                             │
│  Bullet Chart ou Barras com linha de meta (100%)                 │
│  Ordenar por % atingimento DESC                                  │
└─────────────────────────────────────────────────────────────────┘
```

### Objetos Qlik recomendados

| Objeto | Tipo | Dimensão | Medida | Notas |
|---|---|---|---|---|
| Mapa/Treemap Regional | Map ou Treemap | Regiao ou UF | SUM(Valor_Venda) | Drill: Região > UF > Consultor |
| Ranking Consultores | Bar Chart (H) | Nome_Consultor | SUM(Valor_Venda) | Top 10, ordenado DESC |
| % Atingimento | Bullet/Bar Chart | Nome_Consultor | SUM(Valor_Venda)/SUM(Valor_Meta) | Linha de referência em 100% |

### Set Analysis — Hierarquia Comercial

```qlik
// Faturamento da Gerência Regional do usuário logado
SUM({<Gerencia_Regional = {$(=Only(Gerencia_Regional))}>} Valor_Venda)

// Consultores que atingiram a meta
COUNT({<ID_Consultor = {"=SUM(Valor_Venda)/SUM(Valor_Meta) >= 1"}>} DISTINCT ID_Consultor)
```

---

## Sheet 03 — Análise de Produtos

**Objetivo:** Entender *o que* está sendo vendido, por qual canal e com qual rentabilidade.

### Layout sugerido

```
┌─────────────────────────────────────────────────────────────────┐
│  FILTROS: Período | Linha de Produto | Canal de Venda            │
├──────────────────────┬──────────────────┬───────────────────────┤
│ FAT. POR LINHA       │  FAT. POR CANAL  │  % DESCONTO POR       │
│ DE PRODUTO           │  DE VENDA        │  PRODUTO              │
│ (Barras verticais    │  (Donut/Pizza ou │  (Barras H com        │
│  ou Treemap)         │   Barras H)      │   referência em 10%)  │
├──────────────────────┴──────────────────┴───────────────────────┤
│  TABELA DETALHADA: Produto × Canal × Fat. × Desconto × Margem   │
│  Exportável para Excel                                           │
└─────────────────────────────────────────────────────────────────┘
```

### Objetos Qlik recomendados

| Objeto | Tipo | Dimensão | Medida | Notas |
|---|---|---|---|---|
| Fat. por Linha | Bar Chart (V) | Linha_Produto | SUM(Valor_Venda) | Cor por linha |
| Fat. por Canal | Pie/Bar Chart | Canal_Venda | SUM(Valor_Venda) | % do total |
| % Desconto | Bar Chart (H) | Nome_Produto | SUM(Valor_Desconto)/SUM(Valor_Bruto) | Referência: 10% |
| Tabela Detalhe | Table | Nome_Produto, Canal_Venda | Valor_Venda, % Desconto, Margem | Ordenável, exportável |

### Set Analysis — Produtos

```qlik
// % Desconto Médio
SUM(Valor_Desconto) / SUM(Valor_Bruto)

// Margem de Contribuição
SUM(Valor_Venda - Custo_Produto) / SUM(Valor_Venda)

// Produtos com desconto acima da meta (> 10%)
COUNT({<ID_Produto = {"=SUM(Valor_Desconto)/SUM(Valor_Bruto) > 0.10"}>} DISTINCT ID_Produto)
```

---

## Sheet 04 — Financeiro

**Objetivo:** Avaliar a *saúde financeira*: inadimplência, prazo de recebimento e base de clientes.

### Layout sugerido

```
┌─────────────────────────────────────────────────────────────────┐
│  FILTROS: Período | Consultor | Status Financeiro                │
├───────────────┬───────────────┬───────────────┬─────────────────┤
│  Inadimplência│ Prazo Médio   │ Clientes      │ Novos Clientes  │
│  SUM(Atraso)/ │  Pagamento    │  Ativos       │  (1ª compra     │
│  SUM(Total)   │  (dias)       │  (com venda)  │   no mês)       │
│  Meta: < 5%   │  Meta: <30d   │               │                 │
├───────────────┴───────────────┴───────────────┴─────────────────┤
│  INADIMPLÊNCIA POR CLIENTE                                       │
│  Tabela: Cliente | Valor em Atraso | Dias de Atraso | Status     │
│  Ordenar por Valor_Em_Atraso DESC                                │
├─────────────────────────────────────────────────────────────────┤
│  CLIENTES ATIVOS | NOVOS | INATIVOS (Barras agrupadas por mês)  │
└─────────────────────────────────────────────────────────────────┘
```

### Objetos Qlik recomendados

| Objeto | Tipo | Dimensão | Medida | Notas |
|---|---|---|---|---|
| KPI Inadimplência | KPI Card | — | SUM(Valor_Em_Atraso)/SUM(Valor_Total) | Meta: < 5%; cor condicional |
| KPI Prazo Médio | KPI Card | — | Avg(Dias_Atraso) | Meta: < 30 dias |
| KPI Clientes Ativos | KPI Card | — | COUNT(DISTINCT ID_Cliente com venda) | — |
| KPI Novos Clientes | KPI Card | — | COUNT(1ª compra no mês) | — |
| Inadimplência por Cliente | Table | Nome_Cliente | Valor_Em_Atraso, Dias_Atraso | Ordenar DESC |
| Clientes por Segmento | Bar Chart (H) | Segmento (Ativo/Novo/Inativo) | COUNT(DISTINCT ID_Cliente) | Cor por segmento |

### Set Analysis — Financeiro

```qlik
// Inadimplência (%)
SUM({<Status_Financeiro={'Atrasado'}>} Valor_Em_Atraso) / SUM(Valor_Total)

// Clientes Ativos (compraram no período selecionado)
COUNT({<ID_Cliente = {"=SUM(Valor_Venda) > 0"}>} DISTINCT ID_Cliente)

// Novos Clientes (1ª compra no mês atual)
COUNT({<Data_Primeira_Compra = {">=$(=Date(MonthStart(Today()),'DD/MM/YYYY'))"}>} DISTINCT ID_Cliente)

// Clientes Inativos (última compra há mais de 90 dias)
COUNT({<ID_Cliente = {"=Max(Data_Venda) < $(=Today()-90)"}>} DISTINCT ID_Cliente)
```

---

## Resumo de Sheets

| Sheet | Responde | Público Principal |
|---|---|---|
| 01 — Visão Executiva | Estamos atingindo a meta? | Diretor, Gerente |
| 02 — Performance Comercial | Quem e onde performam melhor? | Gerente Comercial |
| 03 — Análise de Produtos | O que e por qual canal vendemos? | Analista, Gerente |
| 04 — Financeiro | A saúde financeira está ok? | Financeiro, Diretor |

---

## Section Access (Controle de Acesso)

Conforme levantamento de requisitos:
```qlik
Section Access;
LOAD * INLINE [
    ACCESS,  USERID,         OMIT
    ADMIN,   DIRETOR_001,
    USER,    GERENTE_SUL,    ID_Consultor
    USER,    CONSULTOR_001,  ID_Consultor; Gerencia_Regional; Regiao
];
Section Application;
```

> Regra: Consultor vê apenas os próprios dados, Gerente Regional vê sua gerência, Diretor vê tudo.

---

## Próximos Passos

- [ ] Validar estrutura de sheets com Gerente Comercial e Analista de BI
- [ ] Confirmar paleta de cores (azul e branco da identidade visual da empresa)
- [ ] Aplicar logo no cabeçalho de cada sheet
- [ ] Configurar Section Access com usuários reais do Qlik Sense
- [ ] Testar Set Analysis com dados reais do ERP Protheus
- [ ] Agendar refresh diário às 06h no Qlik Cloud Management Console
