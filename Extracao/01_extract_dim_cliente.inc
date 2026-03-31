// =============================================================================
// 01_extract_dim_cliente.inc
// Extração: Dimensão Cliente
// Fonte: dbo.Clientes (ERP Protheus / SQL Server)
// Campos: ID_Cliente, Nome_Cliente, Data_Primeira_Compra
// =============================================================================

$(Must_Include=[lib://DataFiles/Extracao/config/conexao.inc]);
$(Must_Include=[lib://DataFiles/Extracao/config/variaveis.inc]);

// -----------------------------------------------------------------------------
// Extração
// Data_Primeira_Compra = MIN(Data_Venda) calculada via subquery nos pedidos
// -----------------------------------------------------------------------------
dim_cliente:
LOAD
    ID_Cliente,
    Nome_Cliente,
    Data_Primeira_Compra
;
SELECT
    c.CodCliente                                    AS ID_Cliente,
    ISNULL(LTRIM(RTRIM(c.NomeCliente)), 'NAO INFORMADO')
                                                    AS Nome_Cliente,
    CAST(MIN(p.DataEmissao) AS DATE)                AS Data_Primeira_Compra
FROM
    dbo.Clientes c
    LEFT JOIN dbo.Pedidos p
        ON p.CodCliente = c.CodCliente
       AND p.DataEmissao BETWEEN '$(vDataInicioSQL)' AND '$(vDataFimSQL)'
GROUP BY
    c.CodCliente,
    c.NomeCliente
;

// -----------------------------------------------------------------------------
// Persistência em QVD
// -----------------------------------------------------------------------------
STORE dim_cliente INTO [$(vPathQVD)dim_cliente.qvd] (qvd);
DROP TABLE dim_cliente;
