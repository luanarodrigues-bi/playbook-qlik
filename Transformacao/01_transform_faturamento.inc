// =============================================================================
// 01_transform_faturamento.inc — Camada de Transformação: Faturamento
// Indicadores cobertos (Biblioteca de Indicadores):
//   [01] Faturamento Realizado         SUM(Valor_Venda)
//   [04] Ticket Médio                  SUM(Valor_Venda) / COUNT(ID_Pedido)
//   [07] Qtd de Pedidos                COUNT(ID_Pedido)
//   [08] Faturamento por Região        SUM(Valor_Venda) GROUP BY Regiao
//   [09] Faturamento por Consultor     SUM(Valor_Venda) GROUP BY Consultor
//   [10] Faturamento por Produto       SUM(Valor_Venda) GROUP BY Produto
//   [11] Faturamento por Canal         SUM(Valor_Venda) GROUP BY Canal_Venda
//   [12] Crescimento MoM               (Fat. Mês Atual - Fat. Mês Anterior) / Fat. Mês Anterior
//   [13] Crescimento YoY               (Fat. Ano Atual - Fat. Ano Anterior) / Fat. Ano Anterior
//   [19] % Desconto Médio              SUM(Valor_Desconto) / SUM(Valor_Bruto)
//   [20] Margem de Contribuição        SUM(Valor_Venda - Custo_Produto) / SUM(Valor_Venda)
// =============================================================================

$(Must_Include=[lib://DataFiles/Extracao/config/variaveis.inc]);

// ─── 1. Carregar QVDs base ────────────────────────────────────────────────────

fato_vendas:
LOAD * FROM [$(vPathQVD)fato_vendas.qvd] (qvd);

dim_tempo:
LOAD * FROM [$(vPathQVD)dim_tempo.qvd] (qvd);

dim_consultor:
LOAD * FROM [$(vPathQVD)dim_consultor.qvd] (qvd);

dim_produto:
LOAD * FROM [$(vPathQVD)dim_produto.qvd] (qvd);

// ─── 2. Campos derivados na fato_vendas ──────────────────────────────────────
// Adicionamos campos calculados diretamente na tabela fato para uso no app
// Nota: AGGR de MoM/YoY é feito via tabela de resumo abaixo (seção 4)

fato_vendas_enriched:
LOAD
    *,
    // Margem de Contribuição unitária por pedido (absoluta)
    (Valor_Venda - Custo_Produto)                       AS Margem_Absoluta,

    // Flag: pedido com desconto acima de 10% (limiar da meta)
    If((Valor_Desconto / Nullif(Valor_Bruto, 0)) > 0.10, 1, 0)
                                                        AS Flag_Desconto_Alto,

    // Flag: pedido fechado (para Taxa de Conversão)
    If(Upper(Status_Pedido) = 'FECHADO', 1, 0)          AS Flag_Fechado,

    // Chave Ano-Mês para análises MoM/YoY (formato YYYYMM)
    Left(Text(ID_Data), 6)                              AS ID_AnoMes
RESIDENT fato_vendas;

DROP TABLE fato_vendas;

// ─── 3. Enriquecimento com dimensões (lookup nos campos de contexto) ──────────
// Aplica Região, UF, Gerência via ApplyMap para evitar JOIN que criaria loops

MAP_Regiao:
MAPPING LOAD ID_Consultor, Regiao        RESIDENT dim_consultor;

MAP_UF:
MAPPING LOAD ID_Consultor, UF           RESIDENT dim_consultor;

MAP_Gerencia:
MAPPING LOAD ID_Consultor, Gerencia_Regional RESIDENT dim_consultor;

MAP_LinhaProduto:
MAPPING LOAD ID_Produto, Linha_Produto  RESIDENT dim_produto;

MAP_AnoMes:
MAPPING LOAD ID_Data, Left(Text(ID_Data), 6) RESIDENT dim_tempo;

// Adiciona campos desnormalizados úteis para Set Analysis no front-end
fato_vendas_final:
LOAD
    *,
    ApplyMap('MAP_Regiao',   ID_Consultor, 'SEM REGIAO')    AS Regiao,
    ApplyMap('MAP_UF',       ID_Consultor, 'N/A')           AS UF,
    ApplyMap('MAP_Gerencia', ID_Consultor, 'SEM GERENCIA')  AS Gerencia_Regional,
    ApplyMap('MAP_LinhaProduto', ID_Produto, 'SEM LINHA')   AS Linha_Produto
RESIDENT fato_vendas_enriched;

DROP TABLE fato_vendas_enriched;
DROP MAP MAP_Regiao, MAP_UF, MAP_Gerencia, MAP_LinhaProduto, MAP_AnoMes;

// ─── 4. Resumo mensal para Crescimento MoM e YoY ─────────────────────────────
// Pré-agrega Faturamento por mês/consultor para suportar comparações período a período
// Usada como tabela auxiliar no app; o cálculo final fica em Set Analysis no front-end

resumo_faturamento_mensal:
LOAD
    ID_Consultor,
    ID_AnoMes,
    Left(Text(ID_AnoMes), 4)                            AS Ano,
    Right(Text(ID_AnoMes), 2)                           AS Mes_Num,
    Sum(Valor_Venda)                                    AS Fat_Mensal,
    Sum(Valor_Bruto)                                    AS Fat_Bruto_Mensal,
    Sum(Valor_Desconto)                                 AS Desconto_Mensal,
    Sum(Custo_Produto)                                  AS Custo_Mensal,
    Count(ID_Pedido)                                    AS Qtd_Pedidos_Mensal,
    Sum(Flag_Fechado)                                   AS Pedidos_Fechados
RESIDENT fato_vendas_final
GROUP BY ID_Consultor, ID_AnoMes;

// ─── 5. Persistência em QVD ──────────────────────────────────────────────────

STORE fato_vendas_final       INTO [lib://DataFiles/Transformacao/QVDs/fato_vendas_final.qvd]       (qvd);
STORE resumo_faturamento_mensal INTO [lib://DataFiles/Transformacao/QVDs/resumo_faturamento_mensal.qvd] (qvd);

DROP TABLE fato_vendas_final;
DROP TABLE resumo_faturamento_mensal;
DROP TABLE dim_tempo;
DROP TABLE dim_consultor;
DROP TABLE dim_produto;
