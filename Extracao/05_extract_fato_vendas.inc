// =============================================================================
// 05_extract_fato_vendas.inc
// Extração: Fato Vendas (granularidade: 1 linha por pedido)
// Fonte: dbo.Pedidos (ERP Protheus / SQL Server)
// Indicadores cobertos:
//   Faturamento Realizado, Ticket Médio, Qtd de Pedidos, % Desconto Médio,
//   Margem de Contribuição, Taxa de Conversão, Fat. por Região/Consultor/
//   Produto/Canal, Crescimento MoM e YoY, Clientes Ativos/Novos/Inativos
// =============================================================================

$(Must_Include=[lib://DataFiles/Extracao/config/conexao.inc]);
$(Must_Include=[lib://DataFiles/Extracao/config/variaveis.inc]);

// -----------------------------------------------------------------------------
// Extração com período filtrado e tratamento de nulos
// ID_Data gerado como YYYYMMDD para join com dim_tempo
// -----------------------------------------------------------------------------
fato_vendas:
LOAD
    ID_Pedido,
    ID_Data,
    ID_Cliente,
    ID_Consultor,
    ID_Produto,
    Canal_Venda,
    Status_Pedido,
    Valor_Venda,
    Valor_Bruto,
    Valor_Desconto,
    Custo_Produto
;
SELECT
    p.NroPedido                                                         AS ID_Pedido,
    CAST(FORMAT(p.DataEmissao, 'yyyyMMdd') AS INT)                      AS ID_Data,
    ISNULL(p.CodCliente,    0)                                          AS ID_Cliente,
    ISNULL(p.CodConsultor,  0)                                          AS ID_Consultor,
    ISNULL(p.CodProduto,    0)                                          AS ID_Produto,
    ISNULL(LTRIM(RTRIM(p.CanalVenda)),   'NAO INFORMADO')               AS Canal_Venda,
    ISNULL(LTRIM(RTRIM(p.StatusPedido)), 'NAO INFORMADO')               AS Status_Pedido,
    ISNULL(p.ValorLiquido,   0)                                         AS Valor_Venda,
    ISNULL(p.ValorBruto,     0)                                         AS Valor_Bruto,
    ISNULL(p.ValorDesconto,  0)                                         AS Valor_Desconto,
    ISNULL(p.CustoProduto,   0)                                         AS Custo_Produto
FROM
    dbo.Pedidos p
WHERE
    p.DataEmissao BETWEEN '$(vDataInicioSQL)' AND '$(vDataFimSQL)'
;

// -----------------------------------------------------------------------------
// Persistência em QVD
// -----------------------------------------------------------------------------
STORE fato_vendas INTO [$(vPathQVD)fato_vendas.qvd] (qvd);
DROP TABLE fato_vendas;
