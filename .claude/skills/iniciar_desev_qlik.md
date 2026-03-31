# SKILL: Iniciar Desenvolvimento Qlik Sense — BIX Tecnologia

## Descrição
Este skill orienta o desenvolvimento completo de projetos Qlik Sense
no padrão BIX Tecnologia, desde a modelagem até a validação técnica.

## Quando usar
- Após preencher todos os templates da etapa de planejamento
- Quando os arquivos abaixo estiverem preenchidos:
  * 01_Levantamento_Requisitos.xlsx
  * 02_Biblioteca_Indicadores.xlsx
  * 03_Data_Request.xlsx

## Pré-requisitos obrigatórios
- `/novo_projeto` já executado
- Templates Excel preenchidos com o usuário de negócio
- Repositório Git configurado

## Padrões BIX obrigatórios

### Scripts
- Extensão `.inc` para TODOS os scripts — nunca `.qvs`
- Modularização por camadas: Extracao → Transformacao → App
- Must_Include para chamar configs e módulos
- Sempre criar `main_load.inc` e `main_transform.inc` como orquestradores

### Estrutura de arquivos .inc
```
Extracao/
├── config/
│   ├── conexao.inc        ← string de conexão
│   └── variaveis.inc      ← variáveis globais
├── XX_extract_dim_[nome].inc
├── XX_extract_fato_[nome].inc
├── main_load.inc          ← orquestrador
└── QVDs/

Transformacao/
├── XX_transform_[grupo].inc
├── main_transform.inc     ← orquestrador
└── QVDs/
```

### Padrão de cada .inc de extração
```qlik
$(Must_Include=[lib://DataFiles/Extracao/config/conexao.inc]);
$(Must_Include=[lib://DataFiles/Extracao/config/variaveis.inc]);

tabela:
LOAD campo1, campo2;
SELECT
    campo_origem AS campo1,
    ISNULL(campo_texto, 'NAO INFORMADO') AS campo2
FROM dbo.tabela
WHERE data BETWEEN '$(vDataInicioSQL)' AND '$(vDataFimSQL)';

STORE tabela INTO [$(vPathQVD)tabela.qvd] (qvd);
DROP TABLE tabela;
```

### Padrão de variaveis.inc
```qlik
LET vDataFim    = Today();
LET vDataInicio = AddMonths(Today(), -24);
SET vRefresh    = '06:00';
SET vPathQVD    = 'lib://DataFiles/Extracao/QVDs/';
```

### Boas práticas Qlik obrigatórias
- Usar ApplyMap em vez de JOIN para evitar chaves sintéticas
- Sempre usar ISNULL() para tratamento de nulos
- Campos numéricos nulos → 0
- Campos texto nulos → 'NAO INFORMADO'
- Sempre fazer STORE → QVD e DROP TABLE
- dim_tempo sempre gerada via AUTOGENERATE — nunca via SQL

### Modelagem
- Sempre modelo estrela — nunca floco de neve
- DDL compatível com a fonte informada no Levantamento:
  * SQL Server → T-SQL
  * Oracle → PL/SQL
  * PostgreSQL → sintaxe PostgreSQL
- Sempre gerar diagrama Mermaid erDiagram em modelo_dados.md

### Storytelling
- Seguir metodologia estratégico ao micro:
  visão geral → regional → individual → detalhe
- Sugerir tipo de visualização para cada indicador com justificativa
- Incluir Set Analysis sugerido para cada objeto Qlik

### Mockup
- Criar no Figma via MCP — servidor: claude.ai Figma
- Autenticação OAuth — nunca Bearer token em arquivo
- Fallback: Excalidraw MCP se Figma não disponível
- Layout padrão BIX:
  * Menu lateral esquerdo azul escuro (#141F38)
  * Área principal branca
  * Um frame por sheet

## Inteligência adaptativa
- Sempre ler os templates antes de gerar qualquer arquivo
- Se fonte de dados mudou nos templates: reescrever arquivos afetados
- Se indicadores mudaram: reescrever transformações afetadas
- NUNCA sobrescrever arquivos .xlsx
- NUNCA recriar o que não mudou

## Erros comuns a evitar
- Usar JOIN em vez de ApplyMap
- Criar chaves sintéticas no modelo
- Usar extensão .qvs em vez de .inc
- Fixar nomes de tabelas no comando - sempre ler do Data Request
- Colocar nomes fixos de arquivos .inc - sempre derivar do Data Request
- Gerar dim_tempo via SQL - sempre usar AUTOGENERATE

## Output esperado
```
 DDL gerado - Extracao/ddl_modelo_estrela.sql
 Diagrama Mermaid - Extracao/modelo_dados.md
 conexao.inc - Extracao/config/conexao.inc
 variaveis.inc - Extracao/config/variaveis.inc
 X scripts de extração - Extracao/XX_extract_*.inc
 main_load.inc - Extracao/main_load.inc
 X scripts de transformação - Transformacao/XX_transform_*.inc
 main_transform.inc - Transformacao/main_transform.inc
 storytelling.md - App/storytelling.md
 Mockup criado no Figma
 relatorio_validacao.md - Documentacao/relatorio_validacao.md
 roteiro_validacao_usuario.md - App/roteiro_validacao_usuario.md
```

## Próximo passo após execução
Apresentar para o usuário de negócio usando o roteiro gerado
e depois rodar /Documentar_Desev._Qlik