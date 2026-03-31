Analise o estado atual do projeto lendo os arquivos existentes.

Verifique a existência e qualidade de cada etapa:

1. Etapa 1 — Planejamento
   Verificar em Documentacao/:
   - 01_Levantamento_Requisitos.xlsx — existe e está preenchido?
   - 02_Biblioteca_Indicadores.xlsx — existe e está preenchido?
   - 03_Data_Request.xlsx — existe e está preenchido?
   - 04_Checklist_Validacao.xlsx — existe e está preenchido?
   - 05_Cronograma.xlsx — existe e está preenchido?
   - 06_Riscos_Projeto.xlsx — existe e está preenchido?

2. Etapa 2 — Desenvolvimento
   Verificar em Extracao/:
   - ddl_modelo_estrela.sql — existe?
   - modelo_dados.md — existe?
   - config/conexao.inc — existe?
   - config/variaveis.inc — existe?
   - Arquivos XX_extract_*.inc — quantos existem?
   - main_load.inc — existe?

   Verificar em Transformacao/:
   - Arquivos XX_transform_*.inc — quantos existem?
   - main_transform.inc — existe?

3. Etapa 3 — App e Validacao
   Verificar em App/:
   - storytelling.md — existe?
   - wireframe_sheets.excalidraw — existe?
   - roteiro_validacao_usuario.md — existe?

   Verificar em Documentacao/:
   - relatorio_validacao.xlsx — existe?
   - Qual a nota atual do relatório?

4. Etapa 4 — Documentacao Final
   Verificar em Documentacao/:
   - doc_entrega.docx — existe?
   - gameday.html — existe?
   - gameday.pptx — existe?
   - datahub.docx — existe?

Leia o 04_Checklist_Validacao.xlsx e extraia:
- Quantos itens estão OK?
- Quantos estão Parcial?
- Quantos estão Pendente?

Antes de gerar, instale as dependências:
pip install openpyxl -q --user

Gere um arquivo Status/status_projeto.xlsx com 2 abas:

Aba 1 — Visão Geral:
- Tabela com as 4 etapas, status e progresso
- Cabeçalho azul escuro
- Status com cores: verde ( completo), amarelo ( parcial), vermelho (pendente)
- Nota atual do checklist em destaque
- Próximo passo recomendado

Aba 2 — Checklist Detalhado:
- Todos os 15 itens do checklist
- Status atual de cada item
- Data de atualização
- Observações

Informe ao usuário:
- Onde o arquivo foi salvo
- Nota atual do projeto
- Próximo passo recomendado