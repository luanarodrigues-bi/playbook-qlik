# Modelo de Dados — Performance Comercial

**Projeto:** Monitoramento de Performance Comercial
**Fontes:** ERP Protheus (SQL Server) · Planilha de Metas (Excel)
**Padrão:** Star Schema (Modelo Estrela)
**Histórico:** 24 meses | **Refresh:** Diário às 6h

---

## Diagrama ER

```mermaid
erDiagram

    %% ─── DIMENSÕES ──────────────────────────────────────────

    dim_tempo {
        int     ID_Data         PK
        date    Data
        int     Dia
        int     Mes
        string  Nome_Mes
        int     Trimestre
        int     Semestre
        int     Ano
        string  Dia_Semana
        boolean Flag_Fim_Semana
    }

    dim_cliente {
        int     ID_Cliente          PK
        string  Nome_Cliente
        date    Data_Primeira_Compra
    }

    dim_consultor {
        int     ID_Consultor        PK
        string  Nome_Consultor
        string  Gerencia_Regional
        string  Regiao
        string  UF
    }

    dim_produto {
        int     ID_Produto          PK
        string  Nome_Produto
        string  Linha_Produto
    }

    %% ─── FATOS ──────────────────────────────────────────────

    fato_vendas {
        int         ID_Pedido       PK
        int         ID_Data         FK
        int         ID_Cliente      FK
        int         ID_Consultor    FK
        int         ID_Produto      FK
        string      Canal_Venda
        string      Status_Pedido
        decimal     Valor_Venda
        decimal     Valor_Bruto
        decimal     Valor_Desconto
        decimal     Custo_Produto
    }

    fato_financeiro {
        int         ID_Titulo               PK
        int         ID_Pedido
        int         ID_Data_Vencimento      FK
        int         ID_Data_Pagamento       FK
        int         ID_Cliente              FK
        string      Status_Financeiro
        decimal     Valor_Total
        decimal     Valor_Em_Atraso
    }

    fato_metas {
        int         ID_Meta         PK
        int         ID_Consultor    FK
        int         ID_Data         FK
        decimal     Valor_Meta
    }

    %% ─── RELACIONAMENTOS ────────────────────────────────────

    dim_tempo       ||--o{ fato_vendas      : "ID_Data"
    dim_cliente     ||--o{ fato_vendas      : "ID_Cliente"
    dim_consultor   ||--o{ fato_vendas      : "ID_Consultor"
    dim_produto     ||--o{ fato_vendas      : "ID_Produto"

    dim_tempo       ||--o{ fato_financeiro  : "ID_Data_Vencimento"
    dim_tempo       ||--o{ fato_financeiro  : "ID_Data_Pagamento"
    dim_cliente     ||--o{ fato_financeiro  : "ID_Cliente"

    dim_consultor   ||--o{ fato_metas       : "ID_Consultor"
    dim_tempo       ||--o{ fato_metas       : "ID_Data"
```

---

## Descrição das Tabelas

### Dimensões

| Tabela | Granularidade | Fonte | Campos-chave |
|---|---|---|---|
| `dim_tempo` | 1 linha por dia | Gerada via script | ID_Data (YYYYMMDD) |
| `dim_cliente` | 1 linha por cliente | dbo.Clientes | ID_Cliente |
| `dim_consultor` | 1 linha por consultor | dbo.Consultores | ID_Consultor |
| `dim_produto` | 1 linha por produto | dbo.Produtos | ID_Produto |

### Fatos

| Tabela | Granularidade | Fonte | Principais Métricas |
|---|---|---|---|
| `fato_vendas` | 1 linha por pedido | dbo.Pedidos | Valor_Venda, Valor_Bruto, Valor_Desconto, Custo_Produto |
| `fato_financeiro` | 1 linha por título/parcela | dbo.Financeiro | Valor_Total, Valor_Em_Atraso |
| `fato_metas` | 1 linha por consultor/mês | dbo.Metas | Valor_Meta |

---

## Hierarquia Comercial (dim_consultor)

```
Diretoria
└── Gerencia_Regional
    └── Nome_Consultor
        └── Regiao / UF
```

> Controle de acesso no Qlik: Consultor vê apenas os próprios dados,
> Gerente Regional vê sua gerência, Diretor vê tudo (Section Access).

---

## Indicadores por Tabela Fato

| Indicador | Fato | Fórmula resumida |
|---|---|---|
| Faturamento Realizado | fato_vendas | SUM(Valor_Venda) |
| Ticket Médio | fato_vendas | SUM(Valor_Venda) / COUNT(ID_Pedido) |
| % Desconto Médio | fato_vendas | SUM(Valor_Desconto) / SUM(Valor_Bruto) |
| Margem de Contribuição | fato_vendas | SUM(Valor_Venda - Custo_Produto) / SUM(Valor_Venda) |
| Taxa de Conversão | fato_vendas | COUNT(Fechados) / COUNT(Total) |
| Inadimplência | fato_financeiro | SUM(Valor_Em_Atraso) / SUM(Valor_Total) |
| Prazo Médio de Pagamento | fato_financeiro | AVG(ID_Data_Pagamento - ID_Data_Vencimento) |
| Meta de Faturamento | fato_metas | SUM(Valor_Meta) |
| % Atingimento de Meta | fato_vendas + fato_metas | SUM(Valor_Venda) / SUM(Valor_Meta) |
