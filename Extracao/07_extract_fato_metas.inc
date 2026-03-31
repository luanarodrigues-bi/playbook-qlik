// =============================================================================
// 07_extract_fato_metas.inc
// Extração: Fato Metas (granularidade: 1 linha por consultor por mês)
// Fonte: dbo.Metas (planilha Excel importada mensalmente para SQL Server)
// Indicadores cobertos:
//   Meta de Faturamento, % Atingimento de Meta
// =============================================================================

$(Must_Include=[lib://DataFiles/Extracao/config/conexao.inc]);
$(Must_Include=[lib://DataFiles/Extracao/config/variaveis.inc]);

// -----------------------------------------------------------------------------
// Extração
// ID_Data aponta para o 1º dia do mês de referência na dim_tempo
// Filtro: meses dentro da janela de 24 meses
// -----------------------------------------------------------------------------
fato_metas:
LOAD
    ID_Meta,
    ID_Consultor,
    ID_Data,
    Valor_Meta
;
SELECT
    m.IdMeta                                                                AS ID_Meta,
    ISNULL(m.CodConsultor, 0)                                               AS ID_Consultor,
    -- 1º dia do mês de referência no formato YYYYMMDD
    CAST(FORMAT(DATEFROMPARTS(m.AnoReferencia, m.MesReferencia, 1),
                'yyyyMMdd') AS INT)                                          AS ID_Data,
    ISNULL(m.ValorMeta, 0)                                                  AS Valor_Meta
FROM
    dbo.Metas m
WHERE
    DATEFROMPARTS(m.AnoReferencia, m.MesReferencia, 1)
        BETWEEN '$(vDataInicioSQL)' AND '$(vDataFimSQL)'
;

// -----------------------------------------------------------------------------
// Persistência em QVD
// -----------------------------------------------------------------------------
STORE fato_metas INTO [$(vPathQVD)fato_metas.qvd] (qvd);
DROP TABLE fato_metas;
