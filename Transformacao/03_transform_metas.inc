// =============================================================================
// 03_transform_metas.inc — Camada de Transformação: Metas
// Indicadores cobertos (Biblioteca de Indicadores):
//   [02] Meta de Faturamento           SUM(Valor_Meta)
//   [03] % Atingimento de Meta         SUM(Valor_Venda) / SUM(Valor_Meta)
//   [18] Valor Médio por Pedido        SUM(Valor_Venda) / COUNT(ID_Pedido)
// =============================================================================

$(Must_Include=[lib://DataFiles/Extracao/config/variaveis.inc]);

// ─── 1. Carregar QVDs base ────────────────────────────────────────────────────

fato_metas:
LOAD * FROM [$(vPathQVD)fato_metas.qvd] (qvd);

dim_consultor:
LOAD * FROM [$(vPathQVD)dim_consultor.qvd] (qvd);

// Carrega resumo de faturamento mensal gerado na transformação de faturamento
// Necessário para calcular % Atingimento (Realizado vs Meta no mesmo nível)
resumo_fat_mensal:
LOAD
    ID_Consultor,
    ID_AnoMes,
    Fat_Mensal,
    Qtd_Pedidos_Mensal
FROM [lib://DataFiles/Transformacao/QVDs/resumo_faturamento_mensal.qvd] (qvd);

// ─── 2. Enriquecer fato_metas com realizado e campos de contexto ──────────────

// Map: realizado por consultor/mês
MAP_Realizado:
MAPPING LOAD
    ID_Consultor & '|' & ID_AnoMes,
    Fat_Mensal
RESIDENT resumo_fat_mensal;

MAP_QtdPedidos:
MAPPING LOAD
    ID_Consultor & '|' & ID_AnoMes,
    Qtd_Pedidos_Mensal
RESIDENT resumo_fat_mensal;

// Maps de dimensão consultor
MAP_Consultor_Nome:
MAPPING LOAD ID_Consultor, Nome_Consultor       RESIDENT dim_consultor;

MAP_Consultor_Gerencia:
MAPPING LOAD ID_Consultor, Gerencia_Regional    RESIDENT dim_consultor;

MAP_Consultor_Regiao:
MAPPING LOAD ID_Consultor, Regiao               RESIDENT dim_consultor;

// Chave de lookup: concatenação ID_Consultor + "|" + ID_AnoMes
fato_metas_enriched:
LOAD
    ID_Meta,
    ID_Consultor,
    ID_Data,
    Left(Text(ID_Data), 6)                                          AS ID_AnoMes,
    Left(Text(ID_Data), 4)                                          AS Ano,
    Right(Left(Text(ID_Data), 6), 2)                                AS Mes_Num,
    Valor_Meta,

    // Realizado no mesmo mês/consultor
    ApplyMap('MAP_Realizado',   ID_Consultor & '|' & Left(Text(ID_Data), 6), 0)
                                                                    AS Fat_Realizado,

    // Qtd de pedidos no mesmo mês/consultor
    ApplyMap('MAP_QtdPedidos',  ID_Consultor & '|' & Left(Text(ID_Data), 6), 0)
                                                                    AS Qtd_Pedidos,

    // % Atingimento de meta (0 = sem meta definida)
    If(
        Valor_Meta > 0,
        ApplyMap('MAP_Realizado', ID_Consultor & '|' & Left(Text(ID_Data), 6), 0)
        / Valor_Meta,
        Null()
    )                                                               AS Pct_Atingimento_Meta,

    // Valor médio por pedido no mês
    If(
        ApplyMap('MAP_QtdPedidos', ID_Consultor & '|' & Left(Text(ID_Data), 6), 0) > 0,
        ApplyMap('MAP_Realizado',  ID_Consultor & '|' & Left(Text(ID_Data), 6), 0)
        / ApplyMap('MAP_QtdPedidos', ID_Consultor & '|' & Left(Text(ID_Data), 6), 0),
        Null()
    )                                                               AS Ticket_Medio_Mensal,

    // Classificação de atingimento (para KPI visual no app)
    If(
        Valor_Meta = 0, 'Sem Meta',
        If(
            ApplyMap('MAP_Realizado', ID_Consultor & '|' & Left(Text(ID_Data), 6), 0)
            / Valor_Meta >= 1,   'Atingido',
            If(
                ApplyMap('MAP_Realizado', ID_Consultor & '|' & Left(Text(ID_Data), 6), 0)
                / Valor_Meta >= 0.8, 'Em Risco',
                'Abaixo da Meta'
            )
        )
    )                                                               AS Status_Meta,

    // Campos de contexto vindos da dimensão consultor
    ApplyMap('MAP_Consultor_Nome',     ID_Consultor, 'NAO INFORMADO') AS Nome_Consultor,
    ApplyMap('MAP_Consultor_Gerencia', ID_Consultor, 'SEM GERENCIA')  AS Gerencia_Regional,
    ApplyMap('MAP_Consultor_Regiao',   ID_Consultor, 'SEM REGIAO')    AS Regiao
RESIDENT fato_metas;

DROP MAP MAP_Realizado, MAP_QtdPedidos;
DROP MAP MAP_Consultor_Nome, MAP_Consultor_Gerencia, MAP_Consultor_Regiao;
DROP TABLE fato_metas;
DROP TABLE resumo_fat_mensal;
DROP TABLE dim_consultor;

// ─── 3. Resumo de metas por gerência e região ─────────────────────────────────
// Agrega no nível gerência/mês para suportar visão gerencial no dashboard

resumo_metas_gerencia:
LOAD
    Gerencia_Regional,
    Regiao,
    ID_AnoMes,
    Ano,
    Mes_Num,
    Sum(Valor_Meta)                                             AS Meta_Gerencia,
    Sum(Fat_Realizado)                                          AS Realizado_Gerencia,
    If(Sum(Valor_Meta) > 0,
       Sum(Fat_Realizado) / Sum(Valor_Meta),
       Null()
    )                                                           AS Pct_Atingimento_Gerencia,
    Count(ID_Meta)                                              AS Qtd_Consultores
RESIDENT fato_metas_enriched
GROUP BY Gerencia_Regional, Regiao, ID_AnoMes, Ano, Mes_Num;

// ─── 4. Persistência em QVD ──────────────────────────────────────────────────

STORE fato_metas_enriched     INTO [lib://DataFiles/Transformacao/QVDs/fato_metas_enriched.qvd]     (qvd);
STORE resumo_metas_gerencia    INTO [lib://DataFiles/Transformacao/QVDs/resumo_metas_gerencia.qvd]    (qvd);

DROP TABLE fato_metas_enriched;
DROP TABLE resumo_metas_gerencia;
