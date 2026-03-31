-- =============================================================================
-- MODELO ESTRELA - PERFORMANCE COMERCIAL
-- Fonte: ERP Protheus (SQL Server) + Planilha de Metas
-- Gerado automaticamente com base em: Data Request + Biblioteca de Indicadores
-- =============================================================================

-- =============================================================================
-- DIMENSOES
-- =============================================================================

CREATE TABLE dim_tempo (
    ID_Data         INTEGER       NOT NULL,   -- YYYYMMDD (ex: 20240315)
    Data            DATE          NOT NULL,
    Dia             SMALLINT      NOT NULL,
    Mes             SMALLINT      NOT NULL,
    Nome_Mes        VARCHAR(20)   NOT NULL,
    Trimestre       SMALLINT      NOT NULL,
    Semestre        SMALLINT      NOT NULL,
    Ano             SMALLINT      NOT NULL,
    Dia_Semana      VARCHAR(15)   NOT NULL,
    Flag_Fim_Semana BOOLEAN       NOT NULL DEFAULT FALSE,
    CONSTRAINT pk_dim_tempo PRIMARY KEY (ID_Data)
);

-- Dimensão Cliente
-- Fonte: dbo.Clientes (ERP Protheus)
CREATE TABLE dim_cliente (
    ID_Cliente          INTEGER       NOT NULL,
    Nome_Cliente        VARCHAR(150)  NOT NULL,
    Data_Primeira_Compra DATE         NULL,     -- MIN(Data_Venda) por cliente
    CONSTRAINT pk_dim_cliente PRIMARY KEY (ID_Cliente)
);

-- Dimensão Consultor (inclui hierarquia comercial)
-- Fonte: dbo.Consultores (ERP Protheus)
-- Hierarquia: Diretoria > Gerencia_Regional > Nome_Consultor
CREATE TABLE dim_consultor (
    ID_Consultor        INTEGER       NOT NULL,
    Nome_Consultor      VARCHAR(150)  NOT NULL,
    Gerencia_Regional   VARCHAR(100)  NULL,
    Regiao              VARCHAR(100)  NULL,     -- Ex: Sul, Sudeste, Norte
    UF                  VARCHAR(2)    NULL,     -- Sigla do estado
    CONSTRAINT pk_dim_consultor PRIMARY KEY (ID_Consultor)
);

-- Dimensão Produto
-- Fonte: dbo.Produtos (ERP Protheus)
CREATE TABLE dim_produto (
    ID_Produto      INTEGER       NOT NULL,
    Nome_Produto    VARCHAR(150)  NOT NULL,
    Linha_Produto   VARCHAR(100)  NULL,         -- Agrupamento por linha
    CONSTRAINT pk_dim_produto PRIMARY KEY (ID_Produto)
);

-- =============================================================================
-- FATOS
-- =============================================================================

-- Fato Vendas (granularidade: 1 linha por pedido)
-- Fonte: dbo.Pedidos (ERP Protheus)
-- Indicadores: Faturamento, Ticket Médio, Qtd Pedidos, % Desconto, Margem,
--              Taxa de Conversão, Faturamento por Região/Consultor/Produto/Canal
CREATE TABLE fato_vendas (
    ID_Pedido       INTEGER         NOT NULL,
    ID_Data         INTEGER         NOT NULL,   -- FK dim_tempo
    ID_Cliente      INTEGER         NOT NULL,   -- FK dim_cliente
    ID_Consultor    INTEGER         NOT NULL,   -- FK dim_consultor
    ID_Produto      INTEGER         NOT NULL,   -- FK dim_produto
    Canal_Venda     VARCHAR(50)     NULL,       -- Direto, Distribuidor, E-commerce
    Status_Pedido   VARCHAR(50)     NULL,       -- Aberto, Fechado, Cancelado
    Valor_Venda     DECIMAL(18,2)   NOT NULL DEFAULT 0, -- Valor líquido após descontos
    Valor_Bruto     DECIMAL(18,2)   NOT NULL DEFAULT 0, -- Valor antes de descontos
    Valor_Desconto  DECIMAL(18,2)   NOT NULL DEFAULT 0, -- Total de desconto aplicado
    Custo_Produto   DECIMAL(18,2)   NOT NULL DEFAULT 0, -- Custo direto do produto
    CONSTRAINT pk_fato_vendas     PRIMARY KEY (ID_Pedido),
    CONSTRAINT fk_fv_tempo        FOREIGN KEY (ID_Data)      REFERENCES dim_tempo     (ID_Data),
    CONSTRAINT fk_fv_cliente      FOREIGN KEY (ID_Cliente)   REFERENCES dim_cliente   (ID_Cliente),
    CONSTRAINT fk_fv_consultor    FOREIGN KEY (ID_Consultor) REFERENCES dim_consultor (ID_Consultor),
    CONSTRAINT fk_fv_produto      FOREIGN KEY (ID_Produto)   REFERENCES dim_produto   (ID_Produto)
);

-- Fato Financeiro (granularidade: 1 linha por parcela/título)
-- Fonte: dbo.Financeiro (ERP Protheus)
-- Indicadores: Inadimplência, Prazo Médio de Pagamento
CREATE TABLE fato_financeiro (
    ID_Titulo           INTEGER         NOT NULL,
    ID_Pedido           INTEGER         NULL,   -- Referência ao pedido de origem
    ID_Data_Vencimento  INTEGER         NOT NULL, -- FK dim_tempo
    ID_Data_Pagamento   INTEGER         NULL,     -- FK dim_tempo (NULL = não pago)
    ID_Cliente          INTEGER         NOT NULL, -- FK dim_cliente
    Status_Financeiro   VARCHAR(50)     NULL,     -- Pago, Atrasado, Pendente
    Valor_Total         DECIMAL(18,2)   NOT NULL DEFAULT 0,
    Valor_Em_Atraso     DECIMAL(18,2)   NOT NULL DEFAULT 0,
    CONSTRAINT pk_fato_financeiro  PRIMARY KEY (ID_Titulo),
    CONSTRAINT fk_ff_vencimento    FOREIGN KEY (ID_Data_Vencimento) REFERENCES dim_tempo   (ID_Data),
    CONSTRAINT fk_ff_pagamento     FOREIGN KEY (ID_Data_Pagamento)  REFERENCES dim_tempo   (ID_Data),
    CONSTRAINT fk_ff_cliente       FOREIGN KEY (ID_Cliente)         REFERENCES dim_cliente (ID_Cliente)
);

-- Fato Metas (granularidade: 1 linha por consultor por mês)
-- Fonte: dbo.Metas / Planilha Excel importada mensalmente
-- Indicadores: Meta de Faturamento, % Atingimento de Meta
CREATE TABLE fato_metas (
    ID_Meta         INTEGER         NOT NULL,
    ID_Consultor    INTEGER         NOT NULL,   -- FK dim_consultor
    ID_Data         INTEGER         NOT NULL,   -- FK dim_tempo (1º dia do mês)
    Valor_Meta      DECIMAL(18,2)   NOT NULL DEFAULT 0,
    CONSTRAINT pk_fato_metas     PRIMARY KEY (ID_Meta),
    CONSTRAINT fk_fm_consultor   FOREIGN KEY (ID_Consultor) REFERENCES dim_consultor (ID_Consultor),
    CONSTRAINT fk_fm_tempo       FOREIGN KEY (ID_Data)      REFERENCES dim_tempo     (ID_Data)
);

-- =============================================================================
-- INDICES DE PERFORMANCE (recomendados para Qlik)
-- =============================================================================

CREATE INDEX idx_fv_data       ON fato_vendas      (ID_Data);
CREATE INDEX idx_fv_cliente    ON fato_vendas      (ID_Cliente);
CREATE INDEX idx_fv_consultor  ON fato_vendas      (ID_Consultor);
CREATE INDEX idx_fv_produto    ON fato_vendas      (ID_Produto);
CREATE INDEX idx_ff_vencimento ON fato_financeiro  (ID_Data_Vencimento);
CREATE INDEX idx_ff_cliente    ON fato_financeiro  (ID_Cliente);
CREATE INDEX idx_fm_consultor  ON fato_metas       (ID_Consultor);
CREATE INDEX idx_fm_data       ON fato_metas       (ID_Data);
