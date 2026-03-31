// =============================================================================
// 02_extract_dim_consultor.inc
// Extração: Dimensão Consultor (inclui hierarquia comercial)
// Fonte: dbo.Consultores (ERP Protheus / SQL Server)
// Hierarquia: Diretoria > Gerencia_Regional > Nome_Consultor
// Campos: ID_Consultor, Nome_Consultor, Gerencia_Regional, Regiao, UF
// =============================================================================

$(Must_Include=[lib://DataFiles/Extracao/config/conexao.inc]);
$(Must_Include=[lib://DataFiles/Extracao/config/variaveis.inc]);

// -----------------------------------------------------------------------------
// Extração
// Tabela de consultores é relativamente estática — sem filtro de período
// -----------------------------------------------------------------------------
dim_consultor:
LOAD
    ID_Consultor,
    Nome_Consultor,
    Gerencia_Regional,
    Regiao,
    UF
;
SELECT
    con.CodConsultor                                        AS ID_Consultor,
    ISNULL(LTRIM(RTRIM(con.NomeConsultor)), 'NAO INFORMADO')
                                                            AS Nome_Consultor,
    ISNULL(LTRIM(RTRIM(con.GerenciaRegional)), 'SEM GERENCIA')
                                                            AS Gerencia_Regional,
    ISNULL(LTRIM(RTRIM(con.Regiao)), 'SEM REGIAO')          AS Regiao,
    ISNULL(UPPER(LTRIM(RTRIM(con.UF))), 'N/A')              AS UF
FROM
    dbo.Consultores con
WHERE
    con.Ativo = 1   -- somente consultores ativos; ajuste conforme campo do ERP
;

// -----------------------------------------------------------------------------
// Persistência em QVD
// -----------------------------------------------------------------------------
STORE dim_consultor INTO [$(vPathQVD)dim_consultor.qvd] (qvd);
DROP TABLE dim_consultor;
