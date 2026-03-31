// =============================================================================
// 03_extract_dim_produto.inc
// Extração: Dimensão Produto
// Fonte: dbo.Produtos (ERP Protheus / SQL Server)
// Campos: ID_Produto, Nome_Produto, Linha_Produto
// =============================================================================

$(Must_Include=[lib://DataFiles/Extracao/config/conexao.inc]);
$(Must_Include=[lib://DataFiles/Extracao/config/variaveis.inc]);

// -----------------------------------------------------------------------------
// Extração
// Tabela de produtos é relativamente estática — sem filtro de período
// -----------------------------------------------------------------------------
dim_produto:
LOAD
    ID_Produto,
    Nome_Produto,
    Linha_Produto
;
SELECT
    prod.CodProduto                                         AS ID_Produto,
    ISNULL(LTRIM(RTRIM(prod.DescricaoProduto)), 'NAO INFORMADO')
                                                            AS Nome_Produto,
    ISNULL(LTRIM(RTRIM(prod.LinhaProduto)), 'SEM LINHA')    AS Linha_Produto
FROM
    dbo.Produtos prod
WHERE
    prod.Ativo = 1  -- somente produtos ativos; ajuste conforme campo do ERP
;

// -----------------------------------------------------------------------------
// Persistência em QVD
// -----------------------------------------------------------------------------
STORE dim_produto INTO [$(vPathQVD)dim_produto.qvd] (qvd);
DROP TABLE dim_produto;
