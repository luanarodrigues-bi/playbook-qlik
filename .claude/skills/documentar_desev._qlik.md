# SKILL: Documentar Desenvolvimento Qlik Sense — BIX Tecnologia

## Descrição
Este skill orienta a geração completa da documentação de entrega
de projetos Qlik Sense no padrão BIX Tecnologia.

## Quando usar
- Após concluir o desenvolvimento e validação técnica
- Quando o /iniciar_desev_qlik já foi executado e validado
- Antes da entrega final ao cliente

## Pré-requisitos obrigatórios
- `/iniciar_desev_qlik` já executado
- `relatorio_validacao.md` gerado
- `App/storytelling.md` gerado
- Templates Excel preenchidos

## Documentos gerados

### 1. Documentação de Entrega — `doc_entrega.docx`
Documento Word técnico completo contendo:
- Resumo do projeto
- Fonte de dados e conexão
- Modelo de dados (tabelas, keys, relacionamentos)
- Scripts de extração (includes, estrutura QVD)
- Scripts de transformação (regras de negócio, Set Analysis)
- Agendamento de carga recomendado
- Section Access configurado
- 20 indicadores com regras de cálculo
- Pendências e próximos passos

### 2. Relatório de Validação — `relatorio_validacao.xlsx`
Excel com 3 abas:
- Aba 1: Checklist com status OK/Parcial/Pendente
- Aba 2: Gaps e sugestões de correção
- Aba 3: Nota final e roadmap para nota 10

### 3. Game Day — `gameday.html` + `gameday.pptx`
Apresentação para o cliente com 8 slides:
- Capa com identidade visual
- Objetivo: problema vs solução
- Sheets entregues com espaço para screenshots
- Tabela de indicadores
- Arquitetura de dados
- Status da validação
- Próximos passos
- Encerramento

### 4. Data Hub — `datahub.docx`
Case study para portfólio comercial contendo:
- Tecnologia utilizada
- Cliente / empresa
- Data da entrega
- Idealizador(es)
- Principais resultados
- Mídia: espaços para prints
- Principais desafios
- Tipo de segmento do cliente
- Área(s) impactada(s)
- Insights relevantes

## Padrões BIX obrigatórios

### Formatos de arquivo
- Documentação técnica → `.docx` (Word)
- Relatório de validação → `.xlsx` (Excel)
- Apresentação → `.html` + `.pptx` (PowerPoint)
- Data Hub → `.docx` (Word)
- NUNCA gerar documentação final em `.md`

### Identidade visual BIX
- Cor primária: azul escuro `#0D2B55`
- Cor secundária: azul médio `#1A4A8A`
- Cor destaque: azul claro `#2E7DD6`
- Fundo: branco `#FFFFFF`
- Tabelas com cabeçalho azul escuro e alternância de linhas

### Game Day — layout dos slides
- Fundo azul escuro no cabeçalho
- Área de conteúdo branca
- Navegação por setas ← →
- Espaços reservados para screenshots do app
- Estilo moderno e profissional

### Relatório de validação — cores por status
- OK → verde `#22C55E`
- Parcial → amarelo `#F59E0B`
- Pendente/Gap → vermelho `#EF4444`

## Dependências Python obrigatórias
```
openpyxl
python-pptx
python-docx
```

Sempre instalar antes de gerar:
```bash
pip install openpyxl python-pptx python-docx -q --user
```

## Regras críticas
- NUNCA sobrescrever arquivos já existentes
- Sempre verificar existência antes de criar
- NUNCA gerar documentação em Markdown  sempre Word/Excel/PPT
- Sempre gerar script Python separado para criar docx/xlsx/pptx
  e remover o script após execução

## Erros comuns a evitar
- Gerar doc_entrega.md em vez de doc_entrega.docx
- Gerar datahub.md em vez de datahub.docx
- Não instalar python-docx antes de gerar Word
- Deixar o script gerar_docs.py no repositório após execução
- Não incluir espaços para screenshots no Game Day

## Output esperado
```
 doc_entrega.docx - Documentacao/doc_entrega.docx
 relatorio_validacao.xlsx - Documentacao/relatorio_validacao.xlsx
 gameday.html - Documentacao/gameday.html
 gameday.pptx - Documentacao/gameday.pptx
 datahub.docx - Documentacao/datahub.docx
```

## Próximo passo após execução
Fazer o commit final e apresentar ao cliente via Game Day:
```bash
git add .
git commit -m "docs: documentação final de entrega gerada"
git push
```