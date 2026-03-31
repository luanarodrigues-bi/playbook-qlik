Leia os arquivos da pasta Documentacao:
- 01_Levantamento_Requisitos.xlsx
- 02_Biblioteca_Indicadores.xlsx
- 03_Data_Request.xlsx

Antes de criar qualquer arquivo ou pasta:
- Leia os arquivos da pasta Documentacao — NUNCA recriar
  ou sobrescrever os arquivos .xlsx, eles são documentos
  preenchidos pelo usuário
- Compare o conteúdo atual dos .xlsx com o que foi usado
  para gerar os arquivos existentes nas pastas Extracao/,
  Transformacao/ e App/
- Se qualquer informação relevante mudou nos .xlsx
  (fonte de dados, indicadores, campos, tabelas, períodos,
  regras de negócio): REESCREVA os arquivos gerados afetados
- Se nada mudou: informe que já existe
- Só crie do zero o que ainda não foi criado

Com base nesses arquivos, gere:

1. Modelagem (salvar em Extracao)
   - Identificar todas as tabelas do Data Request (fatos e dimensões)
   - Gerar DDL compatível com a fonte de dados informada no Levantamento
     * SQL Server: usar T-SQL
     * Oracle: usar PL/SQL
     * PostgreSQL: usar sintaxe PostgreSQL
   - Sugestão de modelo estrela com os relacionamentos entre tabelas
   - Gerar diagrama do modelo em Mermaid (erDiagram) e salvar
     como modelo_dados.md na pasta Extracao

2. Extracao (salvar em Extracao)

   Criar estrutura de pastas:
   - Extracao/config/
   - Extracao/QVDs/

   Criar arquivos em Extracao/config/:
   - conexao.inc
     * String de conexão compatível com a fonte informada no Levantamento
   - variaveis.inc
     * vDataInicio = período histórico informado no Levantamento
     * vDataFim = Today()
     * vRefresh com base no levantamento
     * vPathQVD apontando para pasta QVDs

   Para cada tabela identificada no Data Request, criar um arquivo .inc
   em Extracao/ seguindo a nomenclatura:
   - XX_extract_dim_[nome].inc para dimensões
   - XX_extract_fato_[nome].inc para fatos

   Cada .inc deve:
   - Chamar config/conexao.inc e config/variaveis.inc via Must_Include
   - SELECT com os campos mapeados no Data Request
   - Filtro de período usando vDataInicio e vDataFim
   - Tratamento de nulos com base nos tipos de dado do Data Request
   - Alias nos campos seguindo nomenclatura do DDL gerado
   - Gerar QVD na pasta QVDs/

   Criar Extracao/main_load.inc chamando todos via Must_Include

3. Transformacao (salvar em Transformacao)

   Para cada grupo de indicadores da Biblioteca de Indicadores,
   criar um arquivo .inc em Transformacao/ seguindo a nomenclatura:
   - XX_transform_[grupo].inc

   Cada .inc deve:
   - Chamar config/variaveis.inc via Must_Include
   - Carregar QVDs gerados na Extracao
   - Aplicar Set Analysis para cada indicador do grupo
   - Gerar QVD transformado na pasta Transformacao/QVDs/

   Criar Transformacao/main_transform.inc chamando todos via Must_Include

4. App (salvar em App)

   Criar arquivo storytelling.md em App/ contendo:

   Com base nos indicadores da Biblioteca de Indicadores, sugerir:
   - Para cada indicador: tipo de visualização mais adequado
     (KPI card, linha, barra, donut, bullet, tabela) com justificativa
   - Set Analysis sugerido para cada objeto Qlik
   - Organização lógica dos indicadores por sheet seguindo
     metodologia estratégico ao micro (visão geral > detalhe)

   Criar mockup de alta fidelidade no Figma via MCP do servidor figma
   com a estrutura das sheets sugeridas, seguindo esse layout:
   - Menu lateral esquerdo com grupos de indicadores clicáveis
   - Área principal com grid de gráficos
   - Título da sheet no topo
   - Estilo moderno com fundo azul escuro no menu e branco na área principal
   - Um frame por sheet no Figma

   Criar wireframe também via Excalidraw MCP com a mesma estrutura

5. Validacao Tecnica

   Leia o arquivo Documentacao/04_Checklist_Validacao.xlsx

   Varra todos os arquivos gerados nas pastas:
   - Extracao/
   - Transformacao/
   - App/

   Para cada item do checklist:
   - Verifique se foi implementado
   - Pontue: OK / Parcial / Gap
   - Justifique a avaliação

   Gere um relatório de validacao em Documentacao/relatorio_validacao.md contendo:
   - Tabela com todos os itens do checklist e status
   - Lista de gaps encontrados com sugestão de correção
   - Nota final de 0 a 10 com justificativa

6. Validacao com Usuario de Negocio (salvar em App)

   Com base no relatorio_validacao.md e na Biblioteca de Indicadores,
   criar App/roteiro_validacao_usuario.md contendo:

   - Roteiro de apresentação para o usuário de negócio
   - Lista de indicadores para validar:
     * Nome do indicador
     * Regra de cálculo aplicada
     * Campo: Validado? (Sim / Não / Ajuste necessário)
     * Campo: Observação do usuário
   - Perguntas-chave para confirmar regras de negócio

Antes de iniciar, confirme quais arquivos foram lidos e mostre um resumo
do que vai ser gerado.