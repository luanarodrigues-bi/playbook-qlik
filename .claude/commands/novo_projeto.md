Crie a estrutura inicial de um projeto de dados utilizando Qlik Sense.

Considere:

1. Estrutura de pastas
- Extracao
- Transformacao
- App
- Documentacao

2. Antes de criar os arquivos, verifique se as dependências necessárias estão instaladas.
Crie um arquivo requirements.txt na raiz do projeto com as bibliotecas necessárias e instale-as.

3. Gere templates em formato Excel (.xlsx) para:

- Levantamento de requisitos
  * Gere automaticamente sugestões de perguntas de entrevista
    organizadas por categoria: Contexto, Indicadores, Dados,
    Filtros, Visual e Processo
  * As perguntas devem seguir boas práticas de levantamento
    de requisitos para projetos de BI/Qlik Sense
  * Deixe a coluna "Resposta do Usuário" em branco para preenchimento

- Biblioteca de indicadores
  * Nome do indicador
  * Regra de cálculo
  * Fonte de dados
  * Periodicidade
  * Unidade
  * Meta
  * Responsável
  * Status

- Data Request
  * Campo
  * Tabela origem
  * Tipo (fato ou dimensão)
  * Tipo de dado
  * Formato / Máscara
  * Indicador relacionado
  * Regra de negócio / Transformação
  * Prioridade
  * Status

- Checklist de validação
- Cronograma do projeto
- Riscos do projeto

Antes de criar qualquer arquivo ou pasta, verifique se já existem.
- Se a pasta já existir: não recrie, apenas informe que já existe
- Se o arquivo .xlsx já existir: não sobrescreva, apenas informe que já existe
- Só crie o que ainda não foi criado

Retorne:
- Estrutura de pastas criada
- requirements.txt criado e dependências instaladas
- Arquivos .xlsx prontos para preenchimento salvos na pasta Documentacao