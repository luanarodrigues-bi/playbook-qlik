# SKILL: Novo Projeto Qlik Sense — BIX Tecnologia

## Descrição
Este skill orienta a criação da estrutura inicial de projetos de dados
no padrão BIX Tecnologia usando Qlik Sense e Claude Code.

## Quando usar
- Sempre que um novo projeto de BI/Qlik Sense for iniciado
- Antes de qualquer desenvolvimento  é o ponto de partida
- Após criar o repositório no GitHub e fazer o Git clone

## Estrutura de pastas padrão BIX
```
projeto/
├── Extracao/
│   ├── config/
│   │   ├── conexao.inc
│   │   └── variaveis.inc
│   └── QVDs/
├── Transformacao/
│   └── QVDs/
├── App/
└── Documentacao/
```

## Templates obrigatórios
Sempre gerar em formato `.xlsx`  nunca Markdown para templates:
- `01_Levantamento_Requisitos.xlsx`
- `02_Biblioteca_Indicadores.xlsx`
- `03_Data_Request.xlsx`
- `04_Checklist_Validacao.xlsx`
- `05_Cronograma.xlsx`
- `06_Riscos_Projeto.xlsx`

## Padrões BIX obrigatórios
- Templates sempre em Excel `.xlsx`  nunca `.md` ou `.csv`
- Perguntas de levantamento organizadas por categoria:
  Contexto, Indicadores, Dados, Filtros, Visual, Processo
- Checklist de validação deve cobrir:
  Extração, Transformação, App Qlik, Entrega
- Cronograma deve seguir as fases:
  Kickoff, Extração, Transformação, App Qlik, Validação, Entrega
- Riscos devem usar matriz Probabilidade x Impacto

## Regras críticas
- NUNCA sobrescrever arquivos já existentes
- NUNCA recriar pastas já existentes
- Sempre verificar existência antes de criar
- Sempre instalar dependências via requirements.txt antes de gerar xlsx

## Dependências Python obrigatórias
```
openpyxl
python-pptx
python-docx
```

## Erros comuns a evitar
- Gerar templates em Markdown em vez de Excel
- Criar estrutura de pastas sem verificar se já existe
- Não instalar openpyxl antes de tentar gerar xlsx
- Colocar mcpServers no settings.local.json — use claude mcp add

## Exemplo de output esperado
```
 Pasta Extracao/ criada
 Pasta Transformacao/ criada
 Pasta App/ criada
 Pasta Documentacao/ criada
 requirements.txt criado e dependências instaladas
 01_Levantamento_Requisitos.xlsx salvo em Documentacao/
 02_Biblioteca_Indicadores.xlsx salvo em Documentacao/
 03_Data_Request.xlsx salvo em Documentacao/
 04_Checklist_Validacao.xlsx salvo em Documentacao/
 05_Cronograma.xlsx salvo em Documentacao/
 06_Riscos_Projeto.xlsx salvo em Documentacao/
```

## Próximo passo após execução
Preencher os templates com o usuário de negócio e rodar
o comando /iniciar_desev_qlik