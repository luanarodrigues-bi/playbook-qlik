-- =============================================================================
-- 02_popular_dimensoes.sql
-- Projeto: Performance Comercial — Dados de Teste
-- Popula: dim_tempo, dim_cliente, dim_consultor, dim_produto
-- Pre-requisito: 01_criar_banco.sql executado
-- =============================================================================

USE performance_comercial;
GO

-- ── 1. DIM_TEMPO — Calendario completo dos ultimos 24 meses ───────────────
-- Gera ~730 dias a partir de hoje - 24 meses ate hoje

TRUNCATE TABLE dbo.dim_tempo;

DECLARE @DataInicio DATE = DATEADD(MONTH, -24, CAST(GETDATE() AS DATE));
DECLARE @DataFim    DATE = CAST(GETDATE() AS DATE);
DECLARE @Data       DATE = @DataInicio;

WHILE @Data <= @DataFim
BEGIN
    INSERT INTO dbo.dim_tempo (
        ID_Data, Data, Dia, Mes, Nome_Mes,
        Trimestre, Semestre, Ano, Dia_Semana, Flag_Fim_Semana
    )
    VALUES (
        CAST(FORMAT(@Data, 'yyyyMMdd') AS INT),
        @Data,
        DAY(@Data),
        MONTH(@Data),
        CASE MONTH(@Data)
            WHEN 1  THEN 'Janeiro'   WHEN 2  THEN 'Fevereiro'
            WHEN 3  THEN 'Marco'     WHEN 4  THEN 'Abril'
            WHEN 5  THEN 'Maio'      WHEN 6  THEN 'Junho'
            WHEN 7  THEN 'Julho'     WHEN 8  THEN 'Agosto'
            WHEN 9  THEN 'Setembro'  WHEN 10 THEN 'Outubro'
            WHEN 11 THEN 'Novembro'  WHEN 12 THEN 'Dezembro'
        END,
        DATEPART(QUARTER, @Data),
        CASE WHEN MONTH(@Data) <= 6 THEN 1 ELSE 2 END,
        YEAR(@Data),
        CASE DATEPART(WEEKDAY, @Data)
            WHEN 1 THEN 'Domingo'    WHEN 2 THEN 'Segunda-feira'
            WHEN 3 THEN 'Terca-feira' WHEN 4 THEN 'Quarta-feira'
            WHEN 5 THEN 'Quinta-feira' WHEN 6 THEN 'Sexta-feira'
            WHEN 7 THEN 'Sabado'
        END,
        CASE WHEN DATEPART(WEEKDAY, @Data) IN (1, 7) THEN 1 ELSE 0 END
    );
    SET @Data = DATEADD(DAY, 1, @Data);
END

PRINT CONCAT('dim_tempo: ', (SELECT COUNT(*) FROM dbo.dim_tempo), ' registros inseridos.');
GO

-- ── 2. DIM_CLIENTE — 50 clientes com nomes brasileiros ───────────────────

TRUNCATE TABLE dbo.dim_cliente;

INSERT INTO dbo.dim_cliente (ID_Cliente, Nome_Cliente, Data_Primeira_Compra)
VALUES
( 1, 'Acert Solucoes Empresariais Ltda',          DATEADD(MONTH, -23, GETDATE())),
( 2, 'Alvorada Comercio e Servicos SA',            DATEADD(MONTH, -22, GETDATE())),
( 3, 'Arco Distribuidora Nacional Ltda',           DATEADD(MONTH, -21, GETDATE())),
( 4, 'Azimute Tecnologia e Inovacao SA',           DATEADD(MONTH, -20, GETDATE())),
( 5, 'Barao Equipamentos Industriais Ltda',        DATEADD(MONTH, -19, GETDATE())),
( 6, 'Bela Vista Comercio Atacadista SA',          DATEADD(MONTH, -18, GETDATE())),
( 7, 'Brasfort Industria e Comercio Ltda',         DATEADD(MONTH, -17, GETDATE())),
( 8, 'Caeté Agroindustrial SA',                    DATEADD(MONTH, -16, GETDATE())),
( 9, 'Caminho Real Transportes Ltda',              DATEADD(MONTH, -15, GETDATE())),
(10, 'Capitolio Solucoes Financeiras SA',          DATEADD(MONTH, -14, GETDATE())),
(11, 'Carvao Verde Energia Renovavel Ltda',        DATEADD(MONTH, -13, GETDATE())),
(12, 'Cedrus Consultoria Empresarial SA',          DATEADD(MONTH, -12, GETDATE())),
(13, 'Centaurus Industria Mecanica Ltda',          DATEADD(MONTH, -11, GETDATE())),
(14, 'Circuito Total Eletronicos SA',              DATEADD(MONTH, -10, GETDATE())),
(15, 'Claro Horizonte Comercial Ltda',             DATEADD(MONTH,  -9, GETDATE())),
(16, 'Confluencia Servicos Ltda',                  DATEADD(MONTH,  -8, GETDATE())),
(17, 'Conexao Brasil Distribuidora SA',            DATEADD(MONTH,  -7, GETDATE())),
(18, 'Coroa Imperial Alimentos Ltda',              DATEADD(MONTH,  -6, GETDATE())),
(19, 'Crescente Comercio e Representacoes SA',     DATEADD(MONTH,  -5, GETDATE())),
(20, 'Cruzeiro do Sul Empreendimentos Ltda',       DATEADD(MONTH,  -4, GETDATE())),
(21, 'Delta Engenharia e Construcoes SA',          DATEADD(MONTH,  -3, GETDATE())),
(22, 'Deposito Geral Nordeste Ltda',               DATEADD(MONTH,  -2, GETDATE())),
(23, 'Diamante Azul Textil SA',                    DATEADD(MONTH,  -1, GETDATE())),
(24, 'Eficiencia Total Logistica Ltda',            DATEADD(MONTH, -23, GETDATE())),
(25, 'Estrela Guia Comercio Ltda',                 DATEADD(MONTH, -21, GETDATE())),
(26, 'Expansao Industrial SA',                     DATEADD(MONTH, -19, GETDATE())),
(27, 'Floresta Negra Moveis Ltda',                 DATEADD(MONTH, -17, GETDATE())),
(28, 'Fortaleza Distribuidora Nacional SA',        DATEADD(MONTH, -15, GETDATE())),
(29, 'Fonte Viva Bebidas e Alimentos Ltda',        DATEADD(MONTH, -13, GETDATE())),
(30, 'Garra Industria Plastica SA',                DATEADD(MONTH, -11, GETDATE())),
(31, 'Genese Tecnologia da Informacao Ltda',       DATEADD(MONTH,  -9, GETDATE())),
(32, 'Grão de Ouro Comercio Ltda',                 DATEADD(MONTH,  -7, GETDATE())),
(33, 'Horizonte Azul Servicos SA',                 DATEADD(MONTH,  -5, GETDATE())),
(34, 'Iguacu Representacoes Comerciais Ltda',      DATEADD(MONTH,  -3, GETDATE())),
(35, 'Impacto Forte Publicidade SA',               DATEADD(MONTH,  -2, GETDATE())),
(36, 'Inova Brasil Solucoes Ltda',                 DATEADD(MONTH, -22, GETDATE())),
(37, 'Ipê Dourado Agropecuaria SA',                DATEADD(MONTH, -20, GETDATE())),
(38, 'Itacolomi Mineracao Ltda',                   DATEADD(MONTH, -18, GETDATE())),
(39, 'Jamary Comercio Exterior SA',                DATEADD(MONTH, -16, GETDATE())),
(40, 'Junco Real Atacadista Ltda',                 DATEADD(MONTH, -14, GETDATE())),
(41, 'Lagoa Azul Cosmeticos SA',                   DATEADD(MONTH, -12, GETDATE())),
(42, 'Latitude Sul Tecnologia Ltda',               DATEADD(MONTH, -10, GETDATE())),
(43, 'Leme Navegacao e Comercio SA',               DATEADD(MONTH,  -8, GETDATE())),
(44, 'Linx Industria de Componentes Ltda',         DATEADD(MONTH,  -6, GETDATE())),
(45, 'Mapa Celeste Informatica SA',                DATEADD(MONTH,  -4, GETDATE())),
(46, 'Marco Zero Construtora Ltda',                DATEADD(MONTH,  -2, GETDATE())),
(47, 'Matiz Grafica e Impressao SA',               DATEADD(MONTH, -23, GETDATE())),
(48, 'Meridiano Consultoria SA',                   DATEADD(MONTH, -11, GETDATE())),
(49, 'Nativo Brasil Alimentos Ltda',               DATEADD(MONTH,  -5, GETDATE())),
(50, 'Nordeste Forte Distribuidora SA',            DATEADD(MONTH,  -1, GETDATE()));

PRINT CONCAT('dim_cliente: ', (SELECT COUNT(*) FROM dbo.dim_cliente), ' registros inseridos.');
GO

-- ── 3. DIM_CONSULTOR — 10 consultores com hierarquia ─────────────────────
-- Estrutura: 2 Diretorias > 4 Gerencias > 10 Consultores

TRUNCATE TABLE dbo.dim_consultor;

INSERT INTO dbo.dim_consultor (ID_Consultor, Nome_Consultor, Gerencia_Regional, Regiao, UF)
VALUES
-- Diretoria Sul | Gerencia RS/SC
(1, 'Carlos Eduardo Mendonca',  'Gerencia RS/SC', 'Sul',      'RS'),
(2, 'Fernanda Lima Oliveira',   'Gerencia RS/SC', 'Sul',      'SC'),
(3, 'Ricardo Alves Pinheiro',   'Gerencia PR',    'Sul',      'PR'),
-- Diretoria Sul | Gerencia PR
(4, 'Patricia Souza Barbosa',   'Gerencia PR',    'Sul',      'PR'),
-- Diretoria Sudeste | Gerencia SP
(5, 'Marcelo Rocha Ferreira',   'Gerencia SP',    'Sudeste',  'SP'),
(6, 'Ana Paula Costa Vieira',   'Gerencia SP',    'Sudeste',  'SP'),
(7, 'Bruno Santos Carvalho',    'Gerencia SP',    'Sudeste',  'SP'),
-- Diretoria Sudeste | Gerencia RJ/MG
(8, 'Juliana Pereira Martins',  'Gerencia RJ/MG', 'Sudeste',  'RJ'),
(9, 'Thiago Gomes Ribeiro',     'Gerencia RJ/MG', 'Sudeste',  'MG'),
(10,'Camila Nascimento Araujo', 'Gerencia RJ/MG', 'Sudeste',  'RJ');

PRINT CONCAT('dim_consultor: ', (SELECT COUNT(*) FROM dbo.dim_consultor), ' registros inseridos.');
GO

-- ── 4. DIM_PRODUTO — 20 produtos em 4 linhas ──────────────────────────────

TRUNCATE TABLE dbo.dim_produto;

INSERT INTO dbo.dim_produto (ID_Produto, Nome_Produto, Linha_Produto)
VALUES
-- Linha: Equipamentos Industriais
( 1, 'Compressor de Ar 50L',          'Equipamentos Industriais'),
( 2, 'Compressor de Ar 100L',         'Equipamentos Industriais'),
( 3, 'Grupo Gerador 5 kVA',           'Equipamentos Industriais'),
( 4, 'Grupo Gerador 10 kVA',          'Equipamentos Industriais'),
( 5, 'Balanca Industrial 500kg',       'Equipamentos Industriais'),
-- Linha: Ferramentas e Acessorios
( 6, 'Kit Ferramentas Profissional',   'Ferramentas e Acessorios'),
( 7, 'Furadeira de Bancada',           'Ferramentas e Acessorios'),
( 8, 'Serra Circular 7.1/4"',          'Ferramentas e Acessorios'),
( 9, 'Esmerilhadeira Angular 9"',      'Ferramentas e Acessorios'),
(10, 'Parafusadeira a Bateria',        'Ferramentas e Acessorios'),
-- Linha: Materiais de Construcao
(11, 'Cimento Portland 50kg',          'Materiais de Construcao'),
(12, 'Bloco Ceramico 9 furos (cx100)', 'Materiais de Construcao'),
(13, 'Telha Ceramica Colonial (cx50)', 'Materiais de Construcao'),
(14, 'Vergalhao CA-50 3/8" (barra)',   'Materiais de Construcao'),
(15, 'Tinta Acrilica Premium 18L',     'Materiais de Construcao'),
-- Linha: Seguranca e EPI
(16, 'Capacete de Seguranca CA',       'Seguranca e EPI'),
(17, 'Botina de Seguranca N42',        'Seguranca e EPI'),
(18, 'Kit EPI Completo',               'Seguranca e EPI'),
(19, 'Luva de Seguranca (par)',        'Seguranca e EPI'),
(20, 'Oculos de Protecao UV',          'Seguranca e EPI');

PRINT CONCAT('dim_produto: ', (SELECT COUNT(*) FROM dbo.dim_produto), ' registros inseridos.');
PRINT 'Dimensoes populadas com sucesso. Execute 03_popular_fatos.sql';
GO
