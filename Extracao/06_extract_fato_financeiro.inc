// =============================================================================
// 06_extract_fato_financeiro.inc
// Extração: Fato Financeiro (granularidade: 1 linha por título/parcela)
// Fonte: dbo.Financeiro (ERP Protheus / SQL Server)
// Indicadores cobertos:
//   Inadimplência, Prazo Médio de Pagamento, Valor Total a Receber
// =============================================================================

$(Must_Include=[lib://DataFiles/Extracao/config/conexao.inc]);
$(Must_Include=[lib://DataFiles/Extracao/config/variaveis.inc]);

// -----------------------------------------------------------------------------
// Extração
// Filtro: títulos com DataVencimento dentro do período OU ainda em aberto
// ID_Data_Pagamento pode ser NULL (título não pago) — tratado como 0
// -----------------------------------------------------------------------------
fato_financeiro:
LOAD
    ID_Titulo,
    ID_Pedido,
    ID_Data_Vencimento,
    ID_Data_Pagamento,
    ID_Cliente,
    Status_Financeiro,
    Valor_Total,
    Valor_Em_Atraso
;
SELECT
    f.NroTitulo                                                             AS ID_Titulo,
    ISNULL(f.NroPedido, 0)                                                  AS ID_Pedido,
    CAST(FORMAT(f.DataVencimento, 'yyyyMMdd') AS INT)                       AS ID_Data_Vencimento,
    CASE
        WHEN f.DataPagamento IS NULL THEN 0
        ELSE CAST(FORMAT(f.DataPagamento, 'yyyyMMdd') AS INT)
    END                                                                     AS ID_Data_Pagamento,
    ISNULL(f.CodCliente, 0)                                                 AS ID_Cliente,
    ISNULL(LTRIM(RTRIM(f.StatusFinanceiro)), 'NAO INFORMADO')               AS Status_Financeiro,
    ISNULL(f.ValorTotal,   0)                                               AS Valor_Total,
    CASE
        WHEN f.StatusFinanceiro = 'Atrasado'
             AND f.DataVencimento < GETDATE()
             AND f.DataPagamento IS NULL
        THEN ISNULL(f.ValorTotal, 0)
        ELSE 0
    END                                                                     AS Valor_Em_Atraso
FROM
    dbo.Financeiro f
WHERE
    f.DataVencimento BETWEEN '$(vDataInicioSQL)' AND '$(vDataFimSQL)'
    OR (f.DataPagamento IS NULL AND f.DataVencimento < GETDATE())  -- títulos em aberto
;

// -----------------------------------------------------------------------------
// Persistência em QVD
// -----------------------------------------------------------------------------
STORE fato_financeiro INTO [$(vPathQVD)fato_financeiro.qvd] (qvd);
DROP TABLE fato_financeiro;
