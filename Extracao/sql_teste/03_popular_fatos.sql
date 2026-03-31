-- =============================================================================
-- 03_popular_fatos.sql
-- Projeto: Performance Comercial — Dados de Teste
-- Popula: fato_vendas (5.000 pedidos), fato_financeiro, fato_metas
-- Pre-requisito: 02_popular_dimensoes.sql executado
-- =============================================================================
-- Aleatoriedade determinista: usa ROW_NUMBER + NEWID() + CHECKSUM
-- para garantir distribuicao realista e reproducivel.
-- =============================================================================

USE performance_comercial;
GO

-- ── 1. FATO_VENDAS — 5.000 pedidos em 24 meses ────────────────────────────

TRUNCATE TABLE dbo.fato_vendas;

-- Gera 5000 numeros usando cross join de system tables
WITH Nums AS (
    SELECT TOP 5000
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS N
    FROM sys.all_objects a
    CROSS JOIN sys.all_objects b
),
-- Seleciona datas aleatorias dentro dos 24 meses (apenas dias uteis)
Datas AS (
    SELECT ID_Data, Data,
           ROW_NUMBER() OVER (ORDER BY ID_Data) AS RN_Data,
           COUNT(*) OVER ()                      AS Total_Datas
    FROM dbo.dim_tempo
    WHERE Flag_Fim_Semana = 0
),
-- Monta os pedidos com valores randomicos
Pedidos AS (
    SELECT
        N AS ID_Pedido,

        -- Data: distribui os 5000 pedidos proporcionalmente
        (SELECT d.ID_Data FROM Datas d
         WHERE d.RN_Data = 1 + ABS(CHECKSUM(NEWID())) % (SELECT Total_Datas FROM Datas WHERE RN_Data=1)
        ) AS ID_Data,

        -- Cliente: 1-50
        1 + ABS(CHECKSUM(NEWID())) % 50 AS ID_Cliente,

        -- Consultor: 1-10 com distribuicao maior para SP (5,6,7)
        CASE
            WHEN ABS(CHECKSUM(NEWID())) % 10 < 3 THEN 1 + ABS(CHECKSUM(NEWID())) % 4   -- Sul 40%
            ELSE 5 + ABS(CHECKSUM(NEWID())) % 6                                          -- Sudeste 60%
        END AS ID_Consultor,

        -- Produto: 1-20
        1 + ABS(CHECKSUM(NEWID())) % 20 AS ID_Produto,

        -- Canal: Direto 50%, Distribuidor 35%, E-commerce 15%
        CASE
            WHEN ABS(CHECKSUM(NEWID())) % 100 < 50 THEN 'Direto'
            WHEN ABS(CHECKSUM(NEWID())) % 100 < 85 THEN 'Distribuidor'
            ELSE 'E-commerce'
        END AS Canal_Venda,

        -- Status: Fechado 70%, Aberto 20%, Cancelado 10%
        CASE
            WHEN ABS(CHECKSUM(NEWID())) % 100 < 70 THEN 'Fechado'
            WHEN ABS(CHECKSUM(NEWID())) % 100 < 90 THEN 'Aberto'
            ELSE 'Cancelado'
        END AS Status_Pedido,

        -- Valor bruto: R$1.000 a R$50.000 (distribuicao realista)
        CAST(
            1000.00 + (ABS(CHECKSUM(NEWID())) % 49001) +
            -- Adiciona componente de produto (EPI mais barato, Equipamentos mais caro)
            CASE (1 + ABS(CHECKSUM(NEWID())) % 20)
                WHEN 1 THEN 15000 WHEN 2 THEN 20000 WHEN 3 THEN 18000
                WHEN 4 THEN 22000 WHEN 5 THEN 5000  ELSE 0
            END
        AS DECIMAL(18,2)) AS Valor_Bruto_Raw,

        -- Desconto: 0% a 15%
        CAST((ABS(CHECKSUM(NEWID())) % 16) / 100.0 AS DECIMAL(5,4)) AS Perc_Desconto
    FROM Nums
)
INSERT INTO dbo.fato_vendas (
    ID_Pedido, ID_Data, ID_Cliente, ID_Consultor, ID_Produto,
    Canal_Venda, Status_Pedido,
    Valor_Venda, Valor_Bruto, Valor_Desconto, Custo_Produto
)
SELECT
    p.ID_Pedido,
    -- Garante que ID_Data existe na dim_tempo
    COALESCE(
        (SELECT TOP 1 ID_Data FROM dbo.dim_tempo WHERE Flag_Fim_Semana = 0 ORDER BY NEWID()),
        (SELECT MIN(ID_Data) FROM dbo.dim_tempo)
    ) AS ID_Data,
    p.ID_Cliente,
    p.ID_Consultor,
    p.ID_Produto,
    p.Canal_Venda,
    p.Status_Pedido,
    -- Valor liquido = Bruto * (1 - desconto), cap em 50000
    CAST(LEAST(p.Valor_Bruto_Raw * (1 - p.Perc_Desconto), 50000.00) AS DECIMAL(18,2)),
    CAST(LEAST(p.Valor_Bruto_Raw, 55000.00) AS DECIMAL(18,2)),
    CAST(LEAST(p.Valor_Bruto_Raw * p.Perc_Desconto, 8250.00) AS DECIMAL(18,2)),
    -- Custo: 60-70% do valor liquido (margem 30-40%)
    CAST(LEAST(p.Valor_Bruto_Raw * (1 - p.Perc_Desconto) *
         (0.60 + (ABS(CHECKSUM(NEWID())) % 11) / 100.0), 38000.00) AS DECIMAL(18,2))
FROM Pedidos p;

-- Corrige ID_Data para valores reais da dim_tempo de forma determinista
UPDATE fv
SET fv.ID_Data = dt.ID_Data
FROM dbo.fato_vendas fv
CROSS APPLY (
    SELECT TOP 1 ID_Data
    FROM dbo.dim_tempo
    WHERE Flag_Fim_Semana = 0
    ORDER BY ABS(CHECKSUM(fv.ID_Pedido, fv.ID_Cliente))
) dt;

PRINT CONCAT('fato_vendas: ', (SELECT COUNT(*) FROM dbo.fato_vendas), ' registros inseridos.');
PRINT CONCAT('  Fechados:  ', (SELECT COUNT(*) FROM dbo.fato_vendas WHERE Status_Pedido = 'Fechado'));
PRINT CONCAT('  Abertos:   ', (SELECT COUNT(*) FROM dbo.fato_vendas WHERE Status_Pedido = 'Aberto'));
PRINT CONCAT('  Cancelados:', (SELECT COUNT(*) FROM dbo.fato_vendas WHERE Status_Pedido = 'Cancelado'));
GO

-- ── 2. FATO_FINANCEIRO — titulos baseados nos pedidos fechados ─────────────
-- 80% pagos no prazo | 15% pagos com atraso | 5% inadimplentes

TRUNCATE TABLE dbo.fato_financeiro;

;WITH PedidosFechados AS (
    SELECT
        fv.ID_Pedido,
        fv.ID_Cliente,
        fv.Valor_Venda,
        dt.Data AS DataVenda,
        ROW_NUMBER() OVER (ORDER BY fv.ID_Pedido) AS RN
    FROM dbo.fato_vendas fv
    JOIN dbo.dim_tempo dt ON dt.ID_Data = fv.ID_Data
    WHERE fv.Status_Pedido = 'Fechado'
),
Titulos AS (
    SELECT
        RN AS ID_Titulo,
        ID_Pedido,
        ID_Cliente,
        Valor_Venda AS Valor_Total,
        -- Vencimento: 30 dias apos a venda
        DATEADD(DAY, 30, DataVenda) AS DataVencimento,
        -- Classificacao: 80% pago no prazo, 15% atraso, 5% inadimplente
        CASE
            WHEN RN % 100 < 80 THEN 'Pago'
            WHEN RN % 100 < 95 THEN 'Atrasado'
            ELSE 'Inadimplente'
        END AS StatusFin
    FROM PedidosFechados
)
INSERT INTO dbo.fato_financeiro (
    ID_Titulo, ID_Pedido, ID_Data_Vencimento, ID_Data_Pagamento,
    ID_Cliente, Status_Financeiro, Valor_Total, Valor_Em_Atraso
)
SELECT
    t.ID_Titulo,
    t.ID_Pedido,
    -- ID_Data_Vencimento: primeiro dia do mes do vencimento ou valor mais proximo
    COALESCE(
        (SELECT TOP 1 ID_Data FROM dbo.dim_tempo
         WHERE Data >= t.DataVencimento ORDER BY Data),
        (SELECT MAX(ID_Data) FROM dbo.dim_tempo)
    ),
    -- ID_Data_Pagamento: NULL se inadimplente, data de pagamento se pago
    CASE t.StatusFin
        WHEN 'Pago'      THEN (
            SELECT TOP 1 ID_Data FROM dbo.dim_tempo
            WHERE Data = DATEADD(DAY, ABS(CHECKSUM(t.ID_Titulo)) % 25, t.DataVencimento)
        )
        WHEN 'Atrasado'  THEN (
            SELECT TOP 1 ID_Data FROM dbo.dim_tempo
            WHERE Data >= DATEADD(DAY, 5 + ABS(CHECKSUM(t.ID_Titulo)) % 40, t.DataVencimento)
            ORDER BY Data
        )
        ELSE NULL  -- Inadimplente: sem pagamento
    END,
    t.ID_Cliente,
    CASE t.StatusFin
        WHEN 'Pago'         THEN 'Pago'
        WHEN 'Atrasado'     THEN 'Atrasado'
        ELSE                     'Pendente'
    END,
    t.Valor_Total,
    -- Valor em atraso: 0 para pagos, total para inadimplentes, parcial para atrasados
    CASE t.StatusFin
        WHEN 'Pago'      THEN 0.00
        WHEN 'Atrasado'  THEN CAST(t.Valor_Total * 0.5 AS DECIMAL(18,2))
        ELSE                  t.Valor_Total
    END
FROM Titulos t;

PRINT CONCAT('fato_financeiro: ', (SELECT COUNT(*) FROM dbo.fato_financeiro), ' registros inseridos.');
PRINT CONCAT('  Pagos:       ', (SELECT COUNT(*) FROM dbo.fato_financeiro WHERE Status_Financeiro = 'Pago'));
PRINT CONCAT('  Atrasados:   ', (SELECT COUNT(*) FROM dbo.fato_financeiro WHERE Status_Financeiro = 'Atrasado'));
PRINT CONCAT('  Inadimplentes:', (SELECT COUNT(*) FROM dbo.fato_financeiro WHERE Status_Financeiro = 'Pendente'));
GO

-- ── 3. FATO_METAS — metas mensais por consultor (24 meses) ────────────────
-- Meta base: R$80.000/mes por consultor | Crescimento 5%/mes | variacao +-10%

TRUNCATE TABLE dbo.fato_metas;

;WITH Meses AS (
    -- Primeiro dia util de cada mes nos ultimos 24 meses
    SELECT DISTINCT
        YEAR(Data) AS Ano,
        MONTH(Data) AS Mes,
        MIN(ID_Data) AS ID_Data_Mes
    FROM dbo.dim_tempo
    WHERE Flag_Fim_Semana = 0
    GROUP BY YEAR(Data), MONTH(Data)
),
Consultores AS (
    SELECT ID_Consultor, ROW_NUMBER() OVER (ORDER BY ID_Consultor) AS RN_C
    FROM dbo.dim_consultor
),
Combinacoes AS (
    SELECT
        m.ID_Data_Mes,
        m.Ano,
        m.Mes,
        c.ID_Consultor,
        c.RN_C,
        ROW_NUMBER() OVER (ORDER BY m.Ano, m.Mes, c.ID_Consultor) AS ID_Meta
    FROM Meses m
    CROSS JOIN Consultores c
)
INSERT INTO dbo.fato_metas (ID_Meta, ID_Consultor, ID_Data, Valor_Meta)
SELECT
    ID_Meta,
    ID_Consultor,
    ID_Data_Mes,
    -- Meta = Base R$80k * (1 + 5% * meses_desde_inicio) * fator_consultor
    CAST(
        80000.00
        -- Crescimento acumulado de 5% ao mes (indexado pelo numero do mes na serie)
        * POWER(1.05, (Ano - (SELECT MIN(Ano) FROM Combinacoes)) * 12 + Mes
                    - (SELECT MIN(Mes) FROM Combinacoes WHERE Ano = (SELECT MIN(Ano) FROM Combinacoes)))
        -- Variacao por consultor: +-10% baseado no ID
        * (0.90 + (RN_C % 3) * 0.10)
    AS DECIMAL(18,2))
FROM Combinacoes;

PRINT CONCAT('fato_metas: ', (SELECT COUNT(*) FROM dbo.fato_metas), ' registros inseridos.');
PRINT '';
PRINT '===================================================';
PRINT 'Carga de dados de teste CONCLUIDA com sucesso!';
PRINT 'Execute 04_validar_volumes.sql para conferir.';
PRINT '===================================================';
GO
