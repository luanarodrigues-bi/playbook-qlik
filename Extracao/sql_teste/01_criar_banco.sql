-- =============================================================================
-- 01_criar_banco.sql
-- Projeto: Performance Comercial — Banco de Teste Local
-- Dialeto: T-SQL (SQL Server 2016+)
-- Execucao: SSMS ou Azure Data Studio
-- =============================================================================
-- INSTRUCOES:
--   1. Execute conectado ao servidor local com permissao de CREATE DATABASE
--   2. Apos criar o banco, execute 02_popular_dimensoes.sql
--   3. Depois execute 03_popular_fatos.sql
-- =============================================================================

-- ── 1. Criar banco se nao existir ─────────────────────────────────────────
IF NOT EXISTS (
    SELECT name FROM sys.databases WHERE name = 'performance_comercial'
)
BEGIN
    CREATE DATABASE performance_comercial
        COLLATE Latin1_General_CI_AI;
    PRINT 'Banco performance_comercial criado.';
END
ELSE
    PRINT 'Banco performance_comercial ja existe — pulando criacao.';
GO

USE performance_comercial;
GO

-- ── 2. Criar tabelas (idempotente — recria se ja existir) ──────────────────

-- Dimensao Tempo
IF OBJECT_ID('dbo.dim_tempo', 'U') IS NOT NULL DROP TABLE dbo.dim_tempo;
CREATE TABLE dbo.dim_tempo (
    ID_Data         INT           NOT NULL,   -- YYYYMMDD
    Data            DATE          NOT NULL,
    Dia             SMALLINT      NOT NULL,
    Mes             SMALLINT      NOT NULL,
    Nome_Mes        VARCHAR(20)   NOT NULL,
    Trimestre       SMALLINT      NOT NULL,
    Semestre        SMALLINT      NOT NULL,
    Ano             SMALLINT      NOT NULL,
    Dia_Semana      VARCHAR(15)   NOT NULL,
    Flag_Fim_Semana BIT           NOT NULL DEFAULT 0,
    CONSTRAINT PK_dim_tempo PRIMARY KEY (ID_Data)
);

-- Dimensao Cliente
IF OBJECT_ID('dbo.dim_cliente', 'U') IS NOT NULL DROP TABLE dbo.dim_cliente;
CREATE TABLE dbo.dim_cliente (
    ID_Cliente           INT           NOT NULL,
    Nome_Cliente         VARCHAR(150)  NOT NULL,
    Data_Primeira_Compra DATE          NULL,
    CONSTRAINT PK_dim_cliente PRIMARY KEY (ID_Cliente)
);

-- Dimensao Consultor
IF OBJECT_ID('dbo.dim_consultor', 'U') IS NOT NULL DROP TABLE dbo.dim_consultor;
CREATE TABLE dbo.dim_consultor (
    ID_Consultor       INT           NOT NULL,
    Nome_Consultor     VARCHAR(150)  NOT NULL,
    Gerencia_Regional  VARCHAR(100)  NULL,
    Regiao             VARCHAR(100)  NULL,
    UF                 VARCHAR(2)    NULL,
    CONSTRAINT PK_dim_consultor PRIMARY KEY (ID_Consultor)
);

-- Dimensao Produto
IF OBJECT_ID('dbo.dim_produto', 'U') IS NOT NULL DROP TABLE dbo.dim_produto;
CREATE TABLE dbo.dim_produto (
    ID_Produto    INT           NOT NULL,
    Nome_Produto  VARCHAR(150)  NOT NULL,
    Linha_Produto VARCHAR(100)  NULL,
    CONSTRAINT PK_dim_produto PRIMARY KEY (ID_Produto)
);

-- Fato Vendas
IF OBJECT_ID('dbo.fato_vendas', 'U') IS NOT NULL DROP TABLE dbo.fato_vendas;
CREATE TABLE dbo.fato_vendas (
    ID_Pedido      INT             NOT NULL,
    ID_Data        INT             NOT NULL,
    ID_Cliente     INT             NOT NULL,
    ID_Consultor   INT             NOT NULL,
    ID_Produto     INT             NOT NULL,
    Canal_Venda    VARCHAR(50)     NULL,
    Status_Pedido  VARCHAR(50)     NULL,
    Valor_Venda    DECIMAL(18,2)   NOT NULL DEFAULT 0,
    Valor_Bruto    DECIMAL(18,2)   NOT NULL DEFAULT 0,
    Valor_Desconto DECIMAL(18,2)   NOT NULL DEFAULT 0,
    Custo_Produto  DECIMAL(18,2)   NOT NULL DEFAULT 0,
    CONSTRAINT PK_fato_vendas    PRIMARY KEY (ID_Pedido),
    CONSTRAINT FK_fv_tempo       FOREIGN KEY (ID_Data)      REFERENCES dbo.dim_tempo     (ID_Data),
    CONSTRAINT FK_fv_cliente     FOREIGN KEY (ID_Cliente)   REFERENCES dbo.dim_cliente   (ID_Cliente),
    CONSTRAINT FK_fv_consultor   FOREIGN KEY (ID_Consultor) REFERENCES dbo.dim_consultor (ID_Consultor),
    CONSTRAINT FK_fv_produto     FOREIGN KEY (ID_Produto)   REFERENCES dbo.dim_produto   (ID_Produto)
);

-- Fato Financeiro
IF OBJECT_ID('dbo.fato_financeiro', 'U') IS NOT NULL DROP TABLE dbo.fato_financeiro;
CREATE TABLE dbo.fato_financeiro (
    ID_Titulo          INT             NOT NULL,
    ID_Pedido          INT             NULL,
    ID_Data_Vencimento INT             NOT NULL,
    ID_Data_Pagamento  INT             NULL,
    ID_Cliente         INT             NOT NULL,
    Status_Financeiro  VARCHAR(50)     NULL,
    Valor_Total        DECIMAL(18,2)   NOT NULL DEFAULT 0,
    Valor_Em_Atraso    DECIMAL(18,2)   NOT NULL DEFAULT 0,
    CONSTRAINT PK_fato_financeiro  PRIMARY KEY (ID_Titulo),
    CONSTRAINT FK_ff_vencimento    FOREIGN KEY (ID_Data_Vencimento) REFERENCES dbo.dim_tempo   (ID_Data),
    CONSTRAINT FK_ff_cliente       FOREIGN KEY (ID_Cliente)         REFERENCES dbo.dim_cliente (ID_Cliente)
);

-- Fato Metas
IF OBJECT_ID('dbo.fato_metas', 'U') IS NOT NULL DROP TABLE dbo.fato_metas;
CREATE TABLE dbo.fato_metas (
    ID_Meta      INT             NOT NULL,
    ID_Consultor INT             NOT NULL,
    ID_Data      INT             NOT NULL,
    Valor_Meta   DECIMAL(18,2)   NOT NULL DEFAULT 0,
    CONSTRAINT PK_fato_metas    PRIMARY KEY (ID_Meta),
    CONSTRAINT FK_fm_consultor  FOREIGN KEY (ID_Consultor) REFERENCES dbo.dim_consultor (ID_Consultor),
    CONSTRAINT FK_fm_tempo      FOREIGN KEY (ID_Data)      REFERENCES dbo.dim_tempo     (ID_Data)
);

-- Indices de performance
CREATE INDEX IDX_fv_data      ON dbo.fato_vendas      (ID_Data);
CREATE INDEX IDX_fv_consultor ON dbo.fato_vendas      (ID_Consultor);
CREATE INDEX IDX_fv_cliente   ON dbo.fato_vendas      (ID_Cliente);
CREATE INDEX IDX_ff_venc      ON dbo.fato_financeiro  (ID_Data_Vencimento);
CREATE INDEX IDX_fm_consultor ON dbo.fato_metas       (ID_Consultor);

PRINT 'Todas as tabelas criadas com sucesso.';
PRINT 'Proximo passo: execute 02_popular_dimensoes.sql';
GO
