#  Playbook Completo — Claude Code + Qlik Sense
## BIX Tecnologia | Guia de Configuração e Uso

---

##  Objetivo

Este playbook documenta **tudo** que foi construído e configurado para transformar o Claude Code em um copiloto completo de desenvolvimento de projetos BI com Qlik Sense na BIX Tecnologia.

Cobre desde a instalação do ambiente até a entrega final do projeto, incluindo comandos personalizados, skills, integração com Figma, Git, SQL Server e geração automática de documentação.

---

##  Índice

1. [Pré-requisitos e Instalação](#1-pré-requisitos-e-instalação)
2. [Criação do Projeto e Git](#2-criação-do-projeto-e-git)
3. [Inicialização do Claude Code](#3-inicialização-do-claude-code)
4. [Arquivo CLAUDE.md](#4-arquivo-claudemd)
5. [Estrutura de Pastas](#5-estrutura-de-pastas)
6. [Configuração de Permissões](#6-configuração-de-permissões)
7. [Configuração do Figma MCP](#7-configuração-do-figma-mcp)
8. [Comandos Personalizados](#8-comandos-personalizados)
9. [Skills](#9-skills)
10. [Fluxo Completo do Projeto](#10-fluxo-completo-do-projeto)
11. [Problemas Comuns e Soluções](#11-problemas-comuns-e-soluções)
12. [Boas Práticas e Padrões BIX](#12-boas-práticas-e-padrões-bix)
13. [Arquitetura do Playbook](#13-arquitetura-do-playbook)
14. [Decisões Técnicas](#14-decisões-técnicas)
15. [Governança e Riscos](#15-governança-e-riscos)

---

## 1. Pré-requisitos e Instalação

### 1.1 Node.js
O Claude Code requer Node.js instalado.

```bash
# Verificar se já está instalado
node -v
npm -v
```

Se não estiver instalado, baixar em: https://nodejs.org

### 1.2 Instalação do Claude Code

```bash
npm install -g @anthropic-ai/claude-code
```

### 1.3 Verificar instalação

```bash
claude
```

Se abrir o terminal interativo do Claude, a instalação foi bem-sucedida.

### 1.4 Python
Necessário para geração de arquivos Excel, Word e PowerPoint.

```bash
# Verificar versão
python --version

# Instalar dependências do playbook
pip install openpyxl python-pptx python-docx -q --user
```

> ⚠️ No Windows, sempre usar `--user` para evitar erros de permissão.

---

## 2. Criação do Projeto e Git

### 2.1 Criar pasta do projeto

```bash
mkdir playbook_qlik
cd playbook_qlik
```

### 2.2 Inicializar Git

```bash
git init
```

### 2.3 Criar repositório no GitHub

1. Acessar https://github.com
2. Clicar em **New repository**
3. Nomear o repositório (ex: `playbook-qlik`)
4. **NÃO** inicializar com README
5. Clicar em **Create repository**

### 2.4 Conectar repositório local ao GitHub

```bash
git remote add origin https://github.com/SEU-USUARIO/playbook-qlik.git
git branch -M main
```

### 2.5 Configurar identidade Git

```bash
git config --global user.name "Seu Nome"
git config --global user.email "seu_email@bix.com.br"
```

### 2.6 Primeiro commit e push

```bash
git add .
git commit -m "feat: setup inicial playbook qlik com claude"
git push -u origin main
```

---

## 3. Inicialização do Claude Code

### 3.1 Abrir Claude Code na pasta do projeto

```bash
cd playbook_qlik
claude
```

### 3.2 Rodar comando de análise

```
/init
```

**O que acontece:**
- Claude analisa a estrutura do projeto
- Entende a arquitetura e contexto
- Cria automaticamente o arquivo `CLAUDE.md`

---

## 4. Arquivo CLAUDE.md

### 4.1 O que é
O `CLAUDE.md` é lido **automaticamente** pelo Claude Code toda vez que o projeto é aberto. Funciona como:

- Memória permanente do projeto
- Guia de arquitetura e padrões
- Contexto persistente entre sessões
- Contrato de comportamento com o Claude

### 4.2 Localização
```
playbook_qlik/
└── CLAUDE.md   ← raiz do projeto, fora de qualquer pasta
```

### 4.3 Conteúdo do CLAUDE.md da BIX

```markdown
# Playbook Qlik Sense — BIX Tecnologia

## Sobre este repositório
Este é o playbook oficial de projetos de dados da BIX Tecnologia
usando Qlik Sense e Claude Code.

## Tecnologias
- BI: Qlik Sense
- Scripts: arquivos .inc com Must_Include
- Banco: SQL Server (T-SQL) / ERP Protheus
- Versionamento: Git + GitHub
- Automação: Claude Code

## Padrões obrigatórios
- Scripts sempre com extensão .inc — nunca .qvs
- Templates sempre em Excel .xlsx — nunca Markdown
- Modularização por camadas: Extracao → Transformacao → App
- ApplyMap em vez de JOIN — nunca chaves sintéticas
- STORE → QVD e DROP TABLE em todos os scripts
- dim_tempo sempre via AUTOGENERATE — nunca SQL

## Comandos disponíveis
| Comando | Quando usar |
|---------|-------------|
| /novo_projeto | Início do projeto |
| /iniciar_desev_qlik | Após preencher templates |
| /Documentar_Desev._Qlik | Após validação |
| /status_projeto | Ver progresso atual |
| /corrigir_feedback | Após feedback do usuário |
| /preparar_sql_teste | Criar dados de teste |
| /avaliar_skill | Avaliar e melhorar skills |

## MCPs configurados
- Figma: mockup de alta fidelidade (OAuth)
- Excalidraw: wireframe fallback

## Importante
- NUNCA versionar settings.json ou settings.local.json
- NUNCA expor tokens em arquivos
- SEMPRE usar OAuth para Figma
```

---

## 5. Estrutura de Pastas

### 5.1 Estrutura completa do playbook

```
playbook_qlik/
│
├── CLAUDE.md                    ← lido automaticamente pelo Claude
├── requirements.txt             ← dependências Python
├── .gitignore                   ← arquivos ignorados pelo Git
│
├── .claude/
│   ├── commands/                ← comandos chamados com /
│   │   ├── novo_projeto.md
│   │   ├── iniciar_desev_qlik.md
│   │   ├── Documentar_Desev._Qlik.md
│   │   ├── status_projeto.md
│   │   ├── corrigir_feedback.md
│   │   ├── preparar_sql_teste.md
│   │   └── avaliar_skill.md
│   │
│   ├── skills/                  ← guias de boas práticas
│   │   ├── novo_projeto/
│   │   │   └── SKILL.md
│   │   ├── iniciar_desev_qlik/
│   │   │   └── SKILL.md
│   │   └── documentar_desev_qlik/
│   │       └── SKILL.md
│   │
│   └── docs/                    ← documentação de configuração
│       └── configuracao_figma_mcp.md
│
├── App/                         ← storytelling e wireframes
│   ├── storytelling.md
│   ├── wireframe_sheets.excalidraw
│   └── roteiro_validacao_usuario.md
│
├── Documentacao/                ← templates e docs finais
│   ├── 01_Levantamento_Requisitos.xlsx
│   ├── 02_Biblioteca_Indicadores.xlsx
│   ├── 03_Data_Request.xlsx
│   ├── 04_Checklist_Validacao.xlsx
│   ├── 05_Cronograma.xlsx
│   ├── 06_Riscos_Projeto.xlsx
│   ├── doc_entrega.docx
│   ├── gameday.html
│   ├── gameday.pptx
│   ├── datahub.docx
│   └── relatorio_validacao.xlsx
│
├── Extracao/                    ← scripts de extração
│   ├── ddl_modelo_estrela.sql
│   ├── modelo_dados.md
│   ├── config/
│   │   ├── conexao.inc          ← NÃO versionar!
│   │   └── variaveis.inc        ← NÃO versionar!
│   ├── QVDs/                    ← NÃO versionar!
│   ├── sql_teste/               ← scripts para teste local
│   │   ├── 01_criar_banco.sql
│   │   ├── 02_popular_dimensoes.sql
│   │   ├── 03_popular_fatos.sql
│   │   └── 04_validar_volumes.sql
│   ├── 01_extract_dim_cliente.inc
│   ├── 02_extract_dim_consultor.inc
│   ├── 03_extract_dim_produto.inc
│   ├── 04_extract_dim_tempo.inc
│   ├── 05_extract_fato_vendas.inc
│   ├── 06_extract_fato_financeiro.inc
│   ├── 07_extract_fato_metas.inc
│   └── main_load.inc
│
├── Transformacao/               ← scripts de transformação
│   ├── QVDs/                    ← NÃO versionar!
│   ├── 01_transform_faturamento.inc
│   ├── 02_transform_financeiro.inc
│   ├── 03_transform_metas.inc
│   └── main_transform.inc
│
└── Status/                      ← relatórios de acompanhamento
    ├── status_projeto.xlsx
    └── kpis_esperados.xlsx
```

---

## 6. Configuração de Permissões

### 6.1 Arquivo settings.local.json
Localização: `.claude/settings.local.json`

```json
{
  "permissions": {
    "allow": ["Bash(*)", "Write(*)", "Read(*)"],
    "deny": []
  }
}
```

**O que cada permissão faz:**
- `Bash(*)` — executa qualquer comando no terminal sem pedir permissão
- `Write(*)` — cria e edita qualquer arquivo sem pedir permissão
- `Read(*)` — lê qualquer arquivo sem pedir permissão

> ⚠️ Este arquivo NUNCA deve ser versionado no Git — contém configurações sensíveis.

### 6.2 .gitignore — o que proteger

```gitignore
# Claude Code — ignorar apenas credenciais
.claude/settings.json
.claude/settings.local.json
.claude/.claude.json

# Credenciais e conexões
*.env
.env*
secrets.json
credentials.json
**/config/conexao.inc
**/config/*.pwd
**/config/*.key

# QVDs (dados extraídos do ERP)
**/QVDs/
*.qvd

# Logs e temporários
*.log
*.tmp
*.bak
__pycache__/
*.pyc

# Scripts gerados temporariamente
gerar_docs.py
gen_pptx.py

# Ambientes Python
.venv/
venv/
```

>  A pasta `.claude/commands/` e `.claude/skills/` DEVEM ser versionadas.

---

## 7. Configuração do Figma MCP

### 7.1 Por que OAuth e não Bearer Token
A forma correta de conectar o Figma ao Claude Code é via **OAuth** — não via token manual em arquivo. OAuth é mais seguro porque:
- Não expõe credenciais em arquivos
- Token gerenciado automaticamente
- Nunca vai para o Git acidentalmente

### 7.2 Passo a passo

**Passo 1 — Adicionar servidor MCP**
```bash
claude mcp add --transport http figma-remote-mcp https://mcp.figma.com/mcp
```

**Passo 2 — Reiniciar o Claude Code**
```bash
exit
cd "C:\Users\SEU_USUARIO\SEU_PROJETO"
claude
```

**Passo 3 — Autenticar**
1. Digitar `/mcp` no Claude Code
2. Selecionar **figma-remote-mcp**
3. Browser abre automaticamente
4. Fazer login no Figma e clicar em **Permitir acesso**
5. Voltar ao Claude Code

**Passo 4 — Verificar conexão**
```
/mcp
```

Resultado esperado:
```
claude.ai Figma ·  connected
Status: connected
Tools: 15 tools
```

**Passo 5 — Testar**
```
Usando o MCP do Figma, crie um novo arquivo chamado 
"Teste" e adicione um frame com um retângulo azul.
```

Se abrir arquivo no Figma — está funcionando!

### 7.3 Solução de problemas Figma
- **"needs authentication"** → `/mcp` > selecione Figma > autentique novamente
- **"failed"** → `/mcp` > Clear authentication > reconecte
- **Tools não aparecem** → Reiniciar Claude Code completamente

> ⚠️ NUNCA colocar `mcpServers` no `settings.local.json` — use sempre `claude mcp add`

---

## 8. Comandos Personalizados

Os comandos ficam em `.claude/commands/` e são chamados com `/nome_do_arquivo`.

### 8.1 /novo_projeto
**Quando usar:** Início de qualquer novo projeto BIX

**O que faz:**
- Cria estrutura de pastas: `Extracao`, `Transformacao`, `App`, `Documentacao`
- Instala dependências Python via `requirements.txt`
- Gera 6 templates Excel em branco em `Documentacao/`:
  - `01_Levantamento_Requisitos.xlsx` — perguntas por categoria para entrevistar o usuário
  - `02_Biblioteca_Indicadores.xlsx` — catálogo de KPIs com regras de cálculo
  - `03_Data_Request.xlsx` — mapeamento de campos e tabelas de origem
  - `04_Checklist_Validacao.xlsx` — itens de qualidade por fase
  - `05_Cronograma.xlsx` — fases e atividades com datas
  - `06_Riscos_Projeto.xlsx` — matriz de riscos com probabilidade x impacto

**Regra de ouro:** Nunca sobrescreve arquivos existentes.

---

### 8.2 /iniciar_desev_qlik
**Quando usar:** Após preencher os templates com o usuário de negócio

**O que faz (lendo os templates automaticamente):**

**1. Modelagem**
- Gera DDL completo das tabelas (fatos e dimensões) em T-SQL
- Gera diagrama Mermaid `erDiagram` em `modelo_dados.md`
- Sugere modelo estrela com todos os relacionamentos

**2. Extração**
- Cria `Extracao/config/conexao.inc` — string de conexão com o banco
- Cria `Extracao/config/variaveis.inc` — variáveis globais (período, paths, etc.)
- Gera um arquivo `.inc` por tabela do Data Request
- Cria `main_load.inc` — orquestrador que chama tudo via `Must_Include`

**3. Transformação**
- Gera `.inc` por grupo de indicadores da Biblioteca
- Aplica `ApplyMap` para enriquecer fatos com dimensões (sem JOIN)
- Aplica Set Analysis para cada indicador
- Gera `main_transform.inc` — orquestrador

**4. App**
- Gera `storytelling.md` com sugestão de visualização por indicador
- Cria mockup de alta fidelidade no Figma via MCP
- Cria wireframe no Excalidraw como fallback

**5. Validação Técnica**
- Varre todos os arquivos gerados
- Cruza com o `04_Checklist_Validacao.xlsx`
- Gera `relatorio_validacao.xlsx` com nota de 0 a 10 e gaps

**6. Validação com Usuário**
- Gera `roteiro_validacao_usuario.md` — roteiro para sessão UAT com os 20 indicadores

**Inteligência adaptativa:** Se os templates mudarem (nova fonte, novos campos), ele reescreve só os arquivos afetados. Nunca sobrescreve os `.xlsx`.

---

### 8.3 /Documentar_Desev._Qlik
**Quando usar:** Após validação técnica e com o usuário

**O que gera:**

| Arquivo | Formato | Conteúdo |
|---------|---------|---------|
| `doc_entrega.docx` | Word | Documentação técnica completa |
| `relatorio_validacao.xlsx` | Excel | Checklist, gaps e nota final |
| `gameday.html` | HTML | Apresentação navegável para o cliente |
| `gameday.pptx` | PowerPoint | Versão PPT do Game Day |
| `datahub.docx` | Word | Case study para portfólio comercial |

---

### 8.4 /status_projeto
**Quando usar:** A qualquer momento para ver o progresso

**O que faz:**
- Verifica existência e preenchimento de todos os arquivos
- Lê o checklist de validação
- Gera `Status/status_projeto.xlsx` com:
  - Aba 1: Visão geral das 4 etapas com % de progresso
  - Aba 2: Checklist detalhado com status atual
- Informa nota atual e próximo passo recomendado

---

### 8.5 /corrigir_feedback
**Quando usar:** Após coletar feedbacks na sessão com o usuário de negócio

**Como usar:**
1. Rodar `/corrigir_feedback`
2. Colar os feedbacks recebidos
3. Claude classifica cada feedback por tipo e impacto
4. Gera `Status/plano_correcao.xlsx` com ordem de execução
5. Executa as correções automaticamente nos scripts afetados
6. Atualiza o relatório de validação

---

### 8.6 /preparar_sql_teste
**Quando usar:** Para testar o projeto sem precisar do ERP Protheus

**O que gera:**

| Script | Conteúdo |
|--------|---------|
| `01_criar_banco.sql` | Cria banco e 7 tabelas com FK e índices |
| `02_popular_dimensoes.sql` | 50 clientes, 10 consultores, 20 produtos, 730 dias |
| `03_popular_fatos.sql` | 5.000 pedidos, financeiro e metas |
| `04_validar_volumes.sql` | Queries de COUNT e KPIs para validação |
| `Status/kpis_esperados.xlsx` | KPIs esperados para comparar com o Qlik |

**Como executar no SSMS:**
1. Abrir SSMS ou Azure Data Studio
2. Conectar em `localhost` com permissão `CREATE DATABASE`
3. Executar na ordem: 01 → 02 → 03 → 04

---

### 8.7 /avaliar_skill
**Quando usar:** Para melhorar automaticamente um skill após testá-lo

**Como usar:**
```
/avaliar_skill nome_do_skill
```

**O que faz:**
- Avalia o skill em 5 critérios (0-10 cada)
- Gera `avaliacao.md` com pontuação e justificativas
- Gera `SKILL_melhorado.md` com melhorias aplicadas
- Pergunta se quer substituir o comando atual pelo melhorado

**Critérios de avaliação:**
1. Aderência ao Padrão BIX
2. Qualidade Técnica Qlik/SQL
3. Inteligência Adaptativa
4. Completude do output
5. Tratamento de erros comuns

---

## 9. Skills

Skills ficam em `.claude/skills/[nome]/SKILL.md` e são guias de boas práticas que o Claude lê para fazer melhor.

### 9.1 Diferença entre Command e Skill

| | Command | Skill |
|--|---------|-------|
| Localização | `.claude/commands/` | `.claude/skills/[nome]/` |
| Como acionar | `/nome_do_arquivo` | Lido automaticamente ao executar o comando |
| Conteúdo | Instruções do que fazer | Boas práticas de como fazer bem |
| Analogia | Manual de execução | Guia de qualidade |

### 9.2 Skills criados

**`novo_projeto/SKILL.md`**
- Padrões BIX para templates
- Formato correto dos arquivos (.xlsx, nunca .md)
- Dependências Python obrigatórias
- Erros comuns a evitar

**`iniciar_desev_qlik/SKILL.md`**
- Padrão de scripts .inc com Must_Include
- ApplyMap vs JOIN
- Tratamento de nulos
- dim_tempo via AUTOGENERATE
- Padrão de layout Figma BIX

**`documentar_desev_qlik/SKILL.md`**
- Formatos obrigatórios (docx, xlsx, pptx)
- Identidade visual BIX (cores, fontes)
- Cores por status no checklist
- Estrutura do Game Day

---

## 10. Fluxo Completo do Projeto

```
┌─────────────────────────────────────────────────────────┐
│                  SETUP (uma vez)                        │
│  Instalar Node.js → npm install claude-code             │
│  → git init → criar repo GitHub → claude → /init       │
└─────────────────────────┬───────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────┐
│           ETAPA 1 - NOVO PROJETO                        │
│  Criar repo GitHub → Git clone → /novo_projeto          │
│  → 6 templates Excel gerados em Documentacao/           │
└─────────────────────────┬───────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────┐
│           ETAPA 2 - LEVANTAMENTO (você faz)             │
│  Entrevistar usuário de negócio usando os templates     │
│  → Preencher os 6 xlsx com:                             │
│    - Requisitos, KPIs, campos, riscos, cronograma       │
│  → Git commit dos templates preenchidos                 │
└─────────────────────────┬───────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────┐
│           ETAPA 3 - DESENVOLVIMENTO                     │
│  /iniciar_desev_qlik                                    │
│  → DDL + Mermaid (modelo estrela)                       │
│  → 7+ scripts .inc de extração                          │
│  → 3+ scripts .inc de transformação                     │
│  → storytelling.md + mockup Figma                       │
│  → relatorio_validacao.xlsx (nota 0-10)                 │
│  → roteiro_validacao_usuario.md                         │
│                                                         │
│  Opcional: /preparar_sql_teste                          │
│  → Popular banco local para testar sem ERP              │
└─────────────────────────┬───────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────┐
│           VALIDAÇÃO COM USUÁRIO (você faz)              │
│  Apresentar usando roteiro_validacao_usuario.md         │
│  → Coletar feedbacks                                    │
│  → /corrigir_feedback (ajustes automáticos)             │
└─────────────────────────┬───────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────┐
│           ETAPA 4 — DOCUMENTAÇÃO                        │
│  /Documentar_Desev._Qlik                                │
│  → doc_entrega.docx                                     │
│  → gameday.html + gameday.pptx                          │
│  → datahub.docx                                         │
│  → relatorio_validacao.xlsx (final)                     │
└─────────────────────────┬───────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────┐
│           ETAPA 5 — MELHORIA CONTÍNUA                   │
│  /avaliar_skill [nome]                                  │
│  → Avalia qualidade do skill                            │
│  → Gera versão melhorada automaticamente                │
└─────────────────────────────────────────────────────────┘
```

---

## 11. Problemas Comuns e Soluções

### 🔴 Git — Email errado
**Problema:** Git configurado com email pessoal, GitHub usa email corporativo.

```bash
git config --global user.email "seu_email@bix.com.br"
```

### 🔴 Git — src refspec main does not match any
**Causa:** Não existe commit ainda.

```bash
git add .
git commit -m "first commit"
git push -u origin main
```

### 🔴 Git — Erro 403 Permission denied
**Causa:** Conta autenticada diferente da conta do repositório.

```bash
# Forçar uso do usuário correto
git remote set-url origin https://SEU_USUARIO@github.com/SEU_REPO.git
git push -u origin main
```

### 🔴 Git — Push bloqueado (token exposto)
**Causa:** Token do Figma ou outra credencial commitada acidentalmente.

```bash
# Remover do índice Git
git rm --cached .claude/settings.json
git rm --cached .claude/settings.local.json

# Adicionar ao .gitignore
echo ".claude/settings.json" >> .gitignore
echo ".claude/settings.local.json" >> .gitignore

# Novo commit
git add .
git commit -m "fix: remove credenciais expostas"
git push
```

> ⚠️ Sempre revogar o token exposto no Figma/GitHub e gerar um novo!

### 🔴 Python — pip not found

```bash
# Usar python -m pip
python -m pip install openpyxl python-pptx python-docx -q --user
```

### 🔴 Claude Code — MCP Figma não conecta
**Causa:** `mcpServers` no `settings.local.json` é ignorado — não é o lugar certo.

**Solução correta:**
```bash
claude mcp add --transport http figma-remote-mcp https://mcp.figma.com/mcp
```
Depois reiniciar o Claude Code e autenticar via `/mcp`.

### 🔴 Script Python — unexpected EOF
**Causa:** Heredoc (`cat << 'PYEOF'`) não funciona no Windows.

**Solução:** Sempre usar a ferramenta `Write()` do Claude Code para criar scripts Python temporários.

### 🔴 SQL Server — LEAST() not recognized
**Causa:** Função `LEAST()` só existe no SQL Server 2022+.

**Solução:**
```sql
-- Em vez de LEAST(a, b)
CASE WHEN a < b THEN a ELSE b END
```

---

## 12. Boas Práticas e Padrões BIX

### 12.1 Scripts Qlik

|  Correto |  Errado |
|-----------|----------|
| Extensão `.inc` | Extensão `.qvs` |
| `ApplyMap` para enriquecer | `JOIN` direto |
| `STORE → QVD → DROP TABLE` | Deixar tabela em memória |
| `AUTOGENERATE` para dim_tempo | SQL para dim_tempo |
| `ISNULL(campo, 'NAO INFORMADO')` | Deixar nulo |
| `Must_Include` para configs | Copiar código em cada script |

### 12.2 Padrão de arquivo .inc

```qlik
// =============================================================================
// nome_do_arquivo.inc — Descrição
// Fonte: tabela de origem
// Indicadores cobertos: lista
// =============================================================================

$(Must_Include=[lib://DataFiles/Extracao/config/conexao.inc]);
$(Must_Include=[lib://DataFiles/Extracao/config/variaveis.inc]);

tabela:
LOAD
    campo1,
    campo2;
SELECT
    campo_origem AS campo1,
    ISNULL(campo_texto, 'NAO INFORMADO') AS campo2
FROM dbo.tabela
WHERE data BETWEEN '$(vDataInicioSQL)' AND '$(vDataFimSQL)';

STORE tabela INTO [$(vPathQVD)tabela.qvd] (qvd);
DROP TABLE tabela;
```

### 12.3 Identidade visual BIX

| Elemento | Cor | Hex |
|----------|-----|-----|
| Menu / cabeçalho | Azul escuro | `#0D2B55` |
| Destaque | Azul médio | `#1A4A8A` |
| Accent | Azul claro | `#2E7DD6` |
| Fundo | Branco | `#FFFFFF` |
| Status OK | Verde | `#22C55E` |
| Status Parcial | Amarelo | `#F59E0B` |
| Status Pendente | Vermelho | `#EF4444` |

### 12.4 Commits semânticos

```bash
feat: nova funcionalidade
fix: correção de bug
docs: documentação
refactor: refatoração sem mudança de comportamento
chore: tarefas de manutenção
```

### 12.5 Nunca versionar
- `.claude/settings.json`
- `.claude/settings.local.json`
- `**/config/conexao.inc`
- `**/QVDs/`
- `*.qvd`
- Tokens e credenciais de qualquer tipo

---

## 13. Arquitetura do Playbook

### 13.1 Visão em camadas

```
┌─────────────────────────────────────────────────────────┐
│  CAMADA 1 — ENTRADA                                     │
│  Templates Excel preenchidos pelo usuário de negócio    │
│  01_Levantamento · 02_Biblioteca · 03_DataRequest       │
└─────────────────────────┬───────────────────────────────┘
                          │ input humano
                          ▼
┌─────────────────────────────────────────────────────────┐
│  CAMADA 2 — PROCESSAMENTO                               │
│  Claude Code — interpretação + geração cognitiva        │
│  Lê templates → entende contexto → gera artefatos       │
└─────────────────────────┬───────────────────────────────┘
                          │ scripts gerados
                          ▼
┌─────────────────────────────────────────────────────────┐
│  CAMADA 3 — EXECUÇÃO                                    │
│  Scripts Qlik (.inc) + SQL Server                       │
│  Extração → Transformação → QVDs                        │
└─────────────────────────┬───────────────────────────────┘
                          │ dados processados
                          ▼
┌─────────────────────────────────────────────────────────┐
│  CAMADA 4 — VISUALIZAÇÃO                                │
│  App Qlik Sense + Mockup Figma                          │
│  Dashboards · KPIs · Storytelling                       │
└─────────────────────────┬───────────────────────────────┘
                          │ entrega ao cliente
                          ▼
┌─────────────────────────────────────────────────────────┐
│  CAMADA 5 — SAÍDA                                       │
│  Documentação automatizada                              │
│  doc_entrega · gameday · datahub · relatorio_validacao  │
└─────────────────────────────────────────────────────────┘
```

### 13.2 Princípios de design

| Princípio | Como se aplica |
|-----------|---------------|
| **Separação de responsabilidades** | Cada camada tem uma função clara — input, processamento, execução, visualização, saída |
| **Reprodutibilidade** | Qualquer projeto novo segue o mesmo fluxo — os templates garantem consistência |
| **Baixo acoplamento** | Scripts `.inc` modulares — cada um pode ser atualizado sem afetar os outros |
| **Automação guiada por dados** | Claude lê os templates e adapta o output — sem hardcode de nomes ou campos |
| **Idempotência** | Rodar o mesmo comando duas vezes não destrói trabalho já feito |
| **Rastreabilidade** | Tudo versionado no Git — é possível ver a evolução de cada projeto |

---

## 14. Decisões Técnicas

### 14.1 `.inc` em vez de `.qvs`
**Decisão:** Todos os scripts usam extensão `.inc`

**Justificativa:**
- `.inc` é o padrão para scripts modulares incluídos via `Must_Include`
- Permite separar responsabilidades — cada arquivo tem uma função clara
- Facilita reuso entre projetos
- Evita confusão com scripts de carga principal

### 14.2 `ApplyMap` em vez de `JOIN`
**Decisão:** Enriquecimento de fatos sempre via `ApplyMap`

**Justificativa:**
- `JOIN` no Qlik pode criar chaves sintéticas e loops no modelo
- `ApplyMap` faz lookup pontual sem alterar a estrutura da tabela
- Melhor performance em grandes volumes
- Controle total sobre cardinalidade

```qlik
//  Correto  sem chave sintética
MAP_Regiao:
MAPPING LOAD ID_Consultor, Regiao RESIDENT dim_consultor;

fato_vendas_final:
LOAD *, ApplyMap('MAP_Regiao', ID_Consultor, 'N/A') AS Regiao
RESIDENT fato_vendas;

//  Errado  pode criar chave sintética
JOIN (fato_vendas)
LOAD ID_Consultor, Regiao RESIDENT dim_consultor;
```

### 14.3 Excel como input
**Decisão:** Templates de levantamento sempre em `.xlsx`

**Justificativa:**
- Acessível para qualquer usuário de negócio — sem curva de aprendizado
- Permite formatação, validação e dropdown nativo
- Fácil de preencher em reuniões
- Claude consegue ler via `openpyxl` e interpretar o conteúdo

### 14.4 Claude Code como orquestrador
**Decisão:** Claude Code coordena todo o ciclo de desenvolvimento

**Justificativa:**
- Elimina tarefas repetitivas e manuais
- Garante consistência entre projetos
- Reduz erros humanos na criação de scripts
- Permite que o analista foque no que humanos fazem melhor: entender o negócio

### 14.5 OAuth para Figma
**Decisão:** Autenticação Figma via OAuth — nunca Bearer Token em arquivo

**Justificativa:**
- Token manual em arquivo é risco de segurança — pode ser commitado no Git
- OAuth é gerenciado automaticamente pelo Claude Code
- Não expõe credenciais em nenhum arquivo
- Token renovado automaticamente

### 14.6 Modelo Estrela (Star Schema)
**Decisão:** Sempre modelo estrela — nunca floco de neve

**Justificativa:**
- Melhor performance no Qlik Sense
- Menos joins = menos chaves sintéticas
- Mais simples para o usuário de negócio entender
- Padrão recomendado pela Qlik

---

## 15. Governança e Riscos

### 15.1 Matriz de Riscos

| # | Risco | Probabilidade | Impacto | Nível | Mitigação |
|---|-------|--------------|---------|-------|-----------|
| 1 | Dependência do Claude Code | Média | Alto | **ALTO** | Manter scripts `.inc` legíveis e bem comentados — funcionam sem o Claude |
| 2 | Qualidade dos templates mal preenchidos | Alta | Alto | **CRÍTICO** | Checklist obrigatório + validação com usuário antes de iniciar dev |
| 3 | Erros de interpretação de KPI | Média | Alto | **ALTO** | Roteiro de validação UAT com o usuário de negócio |
| 4 | Token/credencial exposta no Git | Baixa | Alto | **MÉDIO** | `.gitignore` rigoroso + GitHub Secret Scanning ativado |
| 5 | Claude gera código incorreto | Média | Médio | **MÉDIO** | Code review manual antes de executar em produção |
| 6 | Template preenchido de forma ambígua | Alta | Médio | **MÉDIO** | Perguntas padronizadas no Levantamento de Requisitos |
| 7 | Mudança de API do Claude Code | Baixa | Médio | **BAIXO** | Skills documentam boas práticas — fácil de adaptar |

### 15.2 Controles obrigatórios

**Antes de iniciar o desenvolvimento:**
- [ ] Todos os templates Excel preenchidos e revisados
- [ ] Levantamento validado com o usuário de negócio
- [ ] Repositório Git criado e conectado

**Durante o desenvolvimento:**
- [ ] Revisar scripts `.inc` gerados antes de executar
- [ ] Nunca commitar `conexao.inc` ou `settings.json`
- [ ] Manter checklist de validação atualizado

**Antes da entrega:**
- [ ] Nota do checklist ≥ 7,0/10
- [ ] Sessão UAT realizada com aceite formal
- [ ] Documentação final gerada e revisada

### 15.3 Versionamento de outputs

Tudo que o Claude gera deve ser versionado no Git — exceto:
- Arquivos com credenciais (`conexao.inc`, `settings.json`)
- QVDs (dados reais do ERP)
- Logs e temporários

**Por quê versionar os outputs:**
- Rastreabilidade — saber o que foi entregue em cada projeto
- Rollback — voltar para versão anterior se algo quebrar
- Reutilização — reaproveitar scripts de projetos anteriores
- Auditoria — evidência do que foi desenvolvido e quando



---

##  Conclusão

Este playbook transforma o Claude Code em um **copiloto completo** de desenvolvimento BI, cobrindo desde o levantamento de requisitos até a entrega final com documentação profissional.

O diferencial está na **inteligência adaptativa** — o Claude lê os templates preenchidos e se adapta automaticamente ao contexto de cada projeto, sem precisar reconfigurar nada.

Com o ciclo de **avaliação de skills**, o playbook melhora sozinho com o uso — cada projeto entregue torna o próximo mais rápido e com mais qualidade.

---

*Documento gerado em 31/03/2026 | BIX Tecnologia*