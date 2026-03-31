-- =============================================================================
-- 04_validar_volumes.sql
-- Projeto: Performance Comercial — Validacao pos-carga
-- Execucao: apos os 3 scripts anteriores
-- =============================================================================

USE performance_comercial;
GO

-- ── 1. VOLUMES POR TABELA ────────────────────────────────────────────────────

PRINT '==================================================='
PRINT 'VALIDACAO DE VOLUMES — Performance Comercial'
PRINT CONCAT('Executado em: ', CONVERT(VARCHAR, GETDATE(), 120))
PRINT '==================================================='
PRINT ''

SELECT 'dim_tempo'       AS Tabela, COUNT(*) AS Total_Registros FROM dbo.dim_tempo
UNION ALL
SELECT 'dim_cliente',                COUNT(*) FROM dbo.dim_cliente
UNION ALL
SELECT 'dim_consultor',              COUNT(*) FROM dbo.dim_consultor
UNION ALL
SELECT 'dim_produto',                COUNT(*) FROM dbo.dim_produto
UNION ALL
SELECT 'fato_vendas',                COUNT(*) FROM dbo.fato_vendas
UNION ALL
SELECT 'fato_financeiro',            COUNT(*) FROM dbo.fato_financeiro
UNION ALL
SELECT 'fato_metas',                 COUNT(*) FROM dbo.fato_metas
ORDER BY Tabela;

-- ── 2. FATO_VENDAS — distribuicao por status e canal ────────────────────────

PRINT ''
PRINT '--- fato_vendas: status ---'
SELECT
    Status_Pedido,
    COUNT(*)                                           AS Qtd,
    CAST(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER ()
         AS DECIMAL(5,1))                              AS Perc
FROM dbo.fato_vendas
GROUP BY Status_Pedido
ORDER BY Qtd DESC;

PRINT ''
PRINT '--- fato_vendas: canal ---'
SELECT
    Canal_Venda,
    COUNT(*)                                           AS Qtd,
    CAST(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER ()
         AS DECIMAL(5,1))                              AS Perc
FROM dbo.fato_vendas
GROUP BY Canal_Venda
ORDER BY Qtd DESC;

-- ── 3. KPIs FINANCEIROS ──────────────────────────────────────────────────────

PRINT ''
PRINT '--- KPIs fato_vendas ---'
SELECT
    COUNT(*)                                   AS Total_Pedidos,
    COUNT(CASE WHEN Status_Pedido = 'Fechado'    THEN 1 END) AS Fechados,
    COUNT(CASE WHEN Status_Pedido = 'Aberto'     THEN 1 END) AS Abertos,
    COUNT(CASE WHEN Status_Pedido = 'Cancelado'  THEN 1 END) AS Cancelados,

    CAST(SUM(CASE WHEN Status_Pedido = 'Fechado'
                  THEN Valor_Venda ELSE 0 END)
         AS DECIMAL(18,2))                     AS Faturamento_Total,

    CAST(AVG(CASE WHEN Status_Pedido = 'Fechado'
                  THEN Valor_Venda END)
         AS DECIMAL(18,2))                     AS Ticket_Medio,

    CAST(COUNT(CASE WHEN Status_Pedido = 'Fechado' THEN 1 END) * 100.0
         / NULLIF(COUNT(CASE WHEN Status_Pedido IN ('Fechado','Cancelado') THEN 1 END), 0)
         AS DECIMAL(5,1))                      AS Taxa_Conversao_Perc
FROM dbo.fato_vendas;

-- ── 4. KPIs FINANCEIRO (inadimplencia) ──────────────────────────────────────

PRINT ''
PRINT '--- KPIs fato_financeiro ---'
SELECT
    COUNT(*)                                         AS Total_Titulos,
    COUNT(CASE WHEN Status_Financeiro = 'Pago'       THEN 1 END) AS Pagos,
    COUNT(CASE WHEN Status_Financeiro = 'Atrasado'   THEN 1 END) AS Atrasados,
    COUNT(CASE WHEN Status_Financeiro = 'Pendente'   THEN 1 END) AS Inadimplentes,

    CAST(SUM(Valor_Em_Atraso)                        AS DECIMAL(18,2)) AS Valor_Inadimplente,
    CAST(SUM(Valor_Total)                            AS DECIMAL(18,2)) AS Carteira_Total,

    CAST(SUM(Valor_Em_Atraso) * 100.0
         / NULLIF(SUM(Valor_Total), 0)
         AS DECIMAL(5,1))                            AS Inadimplencia_Perc
FROM dbo.fato_financeiro;

-- ── 5. KPIs METAS ────────────────────────────────────────────────────────────

PRINT ''
PRINT '--- KPIs fato_metas ---'
SELECT
    COUNT(DISTINCT ID_Consultor)       AS Consultores,
    COUNT(DISTINCT ID_Data)            AS Meses_Cobertos,
    COUNT(*)                           AS Total_Linhas_Meta,
    CAST(SUM(Valor_Meta) AS DECIMAL(18,2))   AS Meta_Total_Periodo,
    CAST(AVG(Valor_Meta) AS DECIMAL(18,2))   AS Meta_Media_Mensal_Consultor
FROM dbo.fato_metas;

-- ── 6. ATINGIMENTO DE META (vendas fechadas vs metas do periodo) ─────────────

PRINT ''
PRINT '--- Atingimento de Meta por Consultor (ultimos 3 meses) ---'
;WITH UltimosMeses AS (
    SELECT DISTINCT TOP 3
        YEAR(dt.Data)  AS Ano,
        MONTH(dt.Data) AS Mes,
        dt.ID_Data
    FROM dbo.dim_tempo dt
    WHERE dt.Flag_Fim_Semana = 0
    ORDER BY YEAR(dt.Data) DESC, MONTH(dt.Data) DESC
),
VendasConsultor AS (
    SELECT
        fv.ID_Consultor,
        YEAR(dt.Data) AS Ano,
        MONTH(dt.Data) AS Mes,
        SUM(fv.Valor_Venda) AS Realizado
    FROM dbo.fato_vendas fv
    JOIN dbo.dim_tempo dt ON dt.ID_Data = fv.ID_Data
    WHERE fv.Status_Pedido = 'Fechado'
      AND EXISTS (SELECT 1 FROM UltimosMeses um WHERE um.Ano = YEAR(dt.Data) AND um.Mes = MONTH(dt.Data))
    GROUP BY fv.ID_Consultor, YEAR(dt.Data), MONTH(dt.Data)
),
MetasConsultor AS (
    SELECT
        fm.ID_Consultor,
        YEAR(dmt.Data) AS Ano,
        MONTH(dmt.Data) AS Mes,
        fm.Valor_Meta AS Meta
    FROM dbo.fato_metas fm
    JOIN dbo.dim_tempo dmt ON dmt.ID_Data = fm.ID_Data
    WHERE EXISTS (SELECT 1 FROM UltimosMeses um WHERE um.Ano = YEAR(dmt.Data) AND um.Mes = MONTH(dmt.Data))
)
SELECT
    dc.Nome_Consultor,
    m.Ano,
    m.Mes,
    CAST(COALESCE(v.Realizado, 0) AS DECIMAL(18,2))  AS Realizado,
    CAST(m.Meta AS DECIMAL(18,2))                     AS Meta,
    CAST(COALESCE(v.Realizado, 0) * 100.0
         / NULLIF(m.Meta, 0) AS DECIMAL(5,1))         AS Atingimento_Perc
FROM MetasConsultor m
JOIN dbo.dim_consultor dc ON dc.ID_Consultor = m.ID_Consultor
LEFT JOIN VendasConsultor v
       ON v.ID_Consultor = m.ID_Consultor
      AND v.Ano = m.Ano
      AND v.Mes = m.Mes
ORDER BY m.Ano DESC, m.Mes DESC, dc.Nome_Consultor;

-- ── 7. INTEGRIDADE REFERENCIAL ───────────────────────────────────────────────

PRINT ''
PRINT '--- Integridade Referencial ---'
SELECT 'fv.ID_Data sem dim_tempo'       AS Verificacao,
       COUNT(*) AS Orphans
FROM dbo.fato_vendas fv
WHERE NOT EXISTS (SELECT 1 FROM dbo.dim_tempo dt WHERE dt.ID_Data = fv.ID_Data)
UNION ALL
SELECT 'fv.ID_Cliente sem dim_cliente',
       COUNT(*)
FROM dbo.fato_vendas fv
WHERE NOT EXISTS (SELECT 1 FROM dbo.dim_cliente dc WHERE dc.ID_Cliente = fv.ID_Cliente)
UNION ALL
SELECT 'fv.ID_Consultor sem dim_consultor',
       COUNT(*)
FROM dbo.fato_vendas fv
WHERE NOT EXISTS (SELECT 1 FROM dbo.dim_consultor dc WHERE dc.ID_Consultor = fv.ID_Consultor)
UNION ALL
SELECT 'fv.ID_Produto sem dim_produto',
       COUNT(*)
FROM dbo.fato_vendas fv
WHERE NOT EXISTS (SELECT 1 FROM dbo.dim_produto dp WHERE dp.ID_Produto = fv.ID_Produto)
UNION ALL
SELECT 'ff.ID_Data_Vencimento sem dim_tempo',
       COUNT(*)
FROM dbo.fato_financeiro ff
WHERE NOT EXISTS (SELECT 1 FROM dbo.dim_tempo dt WHERE dt.ID_Data = ff.ID_Data_Vencimento);

PRINT ''
PRINT '==================================================='
PRINT 'Validacao concluida!'
PRINT 'Se Orphans = 0 em todos: carga OK para Qlik.'
PRINT '==================================================='
GO
