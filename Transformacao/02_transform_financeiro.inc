// =============================================================================
// 02_transform_financeiro.inc — Camada de Transformação: Financeiro
// Indicadores cobertos (Biblioteca de Indicadores):
//   [06] Inadimplência                 SUM(Valor_Em_Atraso) / SUM(Valor_Total)
//   [14] Qtd de Clientes Ativos        COUNT(DISTINCT ID_Cliente WHERE Valor_Venda > 0)
//   [15] Novos Clientes                Primeira_Compra = Mês Atual
//   [16] Clientes Inativos             Última compra > 90 dias
//   [17] Prazo Médio de Pagamento      AVG(Data_Pagamento - Data_Vencimento)
// =============================================================================

$(Must_Include=[lib://DataFiles/Extracao/config/variaveis.inc]);

// ─── 1. Carregar QVDs base ────────────────────────────────────────────────────

fato_financeiro:
LOAD * FROM [$(vPathQVD)fato_financeiro.qvd] (qvd);

dim_cliente:
LOAD * FROM [$(vPathQVD)dim_cliente.qvd] (qvd);

dim_tempo:
LOAD * FROM [$(vPathQVD)dim_tempo.qvd] (qvd);

// Carrega fato_vendas apenas para calcular clientes ativos/inativos
fato_vendas_ref:
LOAD
    ID_Cliente,
    ID_Data,
    Valor_Venda
FROM [$(vPathQVD)fato_vendas.qvd] (qvd);

// ─── 2. Campos derivados na fato_financeiro ───────────────────────────────────

fato_financeiro_enriched:
LOAD
    *,
    // Dias de atraso: diferença entre data de pagamento e vencimento
    // ID_Data_Pagamento = 0 significa não pago (ver extração)
    If(
        ID_Data_Pagamento > 0,
        Date#(Text(ID_Data_Pagamento), 'YYYYMMDD') - Date#(Text(ID_Data_Vencimento), 'YYYYMMDD'),
        Today() - Date#(Text(ID_Data_Vencimento), 'YYYYMMDD')
    )                                                           AS Dias_Atraso,

    // Flag: título em atraso
    If(
        Status_Financeiro = 'Atrasado'
        AND ID_Data_Pagamento = 0,
        1, 0
    )                                                           AS Flag_Inadimplente,

    // Flag: título pago dentro do prazo
    If(
        ID_Data_Pagamento > 0
        AND Date#(Text(ID_Data_Pagamento), 'YYYYMMDD')
            <= Date#(Text(ID_Data_Vencimento), 'YYYYMMDD'),
        1, 0
    )                                                           AS Flag_Pago_No_Prazo,

    // Chave Ano-Mês do vencimento
    Left(Text(ID_Data_Vencimento), 6)                           AS ID_AnoMes_Vencimento
RESIDENT fato_financeiro;

DROP TABLE fato_financeiro;

// ─── 3. Resumo de inadimplência por cliente e mês ────────────────────────────

resumo_inadimplencia:
LOAD
    ID_Cliente,
    ID_AnoMes_Vencimento,
    Sum(Valor_Total)                                            AS Total_Faturado,
    Sum(Valor_Em_Atraso)                                        AS Total_Em_Atraso,
    Sum(Flag_Inadimplente)                                      AS Qtd_Titulos_Atrasados,
    Avg(If(Flag_Inadimplente = 1, Dias_Atraso))                 AS Prazo_Medio_Atraso,
    Avg(If(ID_Data_Pagamento > 0, Dias_Atraso))                 AS Prazo_Medio_Pagamento
RESIDENT fato_financeiro_enriched
GROUP BY ID_Cliente, ID_AnoMes_Vencimento;

// ─── 4. Classificação de clientes (Ativo / Novo / Inativo) ───────────────────
// Usa a Data_Primeira_Compra e a última compra calculada via AGGR

// Calcula última compra por cliente a partir do fato_vendas
ultima_compra_ref:
LOAD
    ID_Cliente,
    Max(Date#(Text(ID_Data), 'YYYYMMDD'))                       AS Data_Ultima_Compra
RESIDENT fato_vendas_ref
GROUP BY ID_Cliente;

MAP_UltimaCompra:
MAPPING LOAD ID_Cliente, Data_Ultima_Compra RESIDENT ultima_compra_ref;

DROP TABLE ultima_compra_ref;

dim_cliente_enriched:
LOAD
    ID_Cliente,
    Nome_Cliente,
    Data_Primeira_Compra,
    ApplyMap('MAP_UltimaCompra', ID_Cliente, Null())            AS Data_Ultima_Compra,

    // Flag: cliente ativo (comprou dentro dos últimos 90 dias)
    If(
        ApplyMap('MAP_UltimaCompra', ID_Cliente, 0) >= Today() - 90,
        1, 0
    )                                                           AS Flag_Cliente_Ativo,

    // Flag: cliente inativo (sem compra há mais de 90 dias)
    If(
        ApplyMap('MAP_UltimaCompra', ID_Cliente, 0) < Today() - 90
        OR IsNull(ApplyMap('MAP_UltimaCompra', ID_Cliente, Null())),
        1, 0
    )                                                           AS Flag_Cliente_Inativo,

    // Flag: novo cliente (primeira compra no mês corrente)
    If(
        Month(Data_Primeira_Compra) = Month(Today())
        AND Year(Data_Primeira_Compra)  = Year(Today()),
        1, 0
    )                                                           AS Flag_Cliente_Novo
RESIDENT dim_cliente;

DROP MAP MAP_UltimaCompra;
DROP TABLE dim_cliente;
DROP TABLE fato_vendas_ref;

// ─── 5. Persistência em QVD ──────────────────────────────────────────────────

STORE fato_financeiro_enriched  INTO [lib://DataFiles/Transformacao/QVDs/fato_financeiro_enriched.qvd]  (qvd);
STORE resumo_inadimplencia       INTO [lib://DataFiles/Transformacao/QVDs/resumo_inadimplencia.qvd]       (qvd);
STORE dim_cliente_enriched       INTO [lib://DataFiles/Transformacao/QVDs/dim_cliente_enriched.qvd]       (qvd);

DROP TABLE fato_financeiro_enriched;
DROP TABLE resumo_inadimplencia;
DROP TABLE dim_cliente_enriched;
DROP TABLE dim_tempo;
