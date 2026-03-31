Leia todos os arquivos gerados no projeto:
- Documentacao/01_Levantamento_Requisitos.xlsx
- Documentacao/02_Biblioteca_Indicadores.xlsx
- Documentacao/03_Data_Request.xlsx
- Documentacao/relatorio_validacao.md
- Extracao/modelo_dados.md
- Extracao/ddl_modelo_estrela.sql
- Extracao/config/conexao.inc
- Extracao/config/variaveis.inc
- Extracao/main_load.inc
- Transformacao/main_transform.inc
- App/storytelling.md

Antes de gerar qualquer arquivo:
1. Atualize o requirements.txt adicionando se não existir:
   - openpyxl
   - python-pptx
   - python-docx

2. Instale as dependências:
   pip install openpyxl python-pptx python-docx -q --user

Com base nesses arquivos, gere:

1. Documentacao de Entrega (salvar em Documentacao/)

   Criar Documentacao/doc_entrega.docx contendo:
   - Resumo do projeto
   - Fonte de dados e conexão
   - Modelo de dados (tabelas, keys, relacionamentos)
   - Scripts de extração (includes, estrutura QVD)
   - Scripts de transformação (regras de negócio, Set Analysis)
   - Agendamento de carga recomendado
   - Section Access configurado
   - Indicadores entregues com regras de cálculo
   - Pendências e próximos passos

2. Relatorio de Validacao (salvar em Documentacao/)

   Criar Documentacao/relatorio_validacao.xlsx contendo:
   - Aba 1: Tabela com todos os itens do checklist e status
   - Aba 2: Lista de gaps com sugestão de correção
   - Aba 3: Nota final com justificativa e roadmap

3. Game Day (salvar em Documentacao/)

   Criar Documentacao/gameday.html contendo:
   - Apresentação visual do projeto para o cliente
   - Slides com: objetivo, solução entregue, indicadores,
     arquitetura de dados, próximos passos
   - Estilo moderno com cores azul e branco
   - Espaços reservados para prints das telas do app

   Converter Documentacao/gameday.html para
   Documentacao/gameday.pptx

4. Data Hub (salvar em Documentacao/)

   Criar Documentacao/datahub.docx contendo:
   - Tecnologia utilizada
   - Cliente / empresa
   - Data da entrega
   - Idealizador(es)
   - Principais resultados
   - Mídia: espaços para prints dos painéis e fluxos
   - Principais desafios
   - Tipo de segmento do cliente
   - Área(s) impactada(s)
   - Insights relevantes

Antes de criar qualquer arquivo, verifique se já existem.
- Se já existir: não recrie, apenas informe que já existe
- Só crie o que ainda não foi criado