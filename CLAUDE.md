# Playbook Qlik Sense — BIX Tecnologia

## Sobre este repositório
Este é o playbook oficial de projetos de dados da BIX Tecnologia
usando Qlik Sense e Claude Code.

## Tecnologias
- **BI:** Qlik Sense
- **Scripts:** arquivos .inc com Must_Include
- **Banco:** SQL Server (T-SQL) / ERP Protheus
- **Versionamento:** Git + GitHub
- **Automação:** Claude Code

## Padrões obrigatórios
- Scripts sempre com extensão `.inc` — nunca `.qvs`
- Templates sempre em Excel `.xlsx` — nunca Markdown
- Modularização por camadas: Extracao → Transformacao → App
- ApplyMap em vez de JOIN — nunca chaves sintéticas
- STORE → QVD e DROP TABLE em todos os scripts
- dim_tempo sempre via AUTOGENERATE — nunca SQL

## Estrutura de comandos
| Comando | Quando usar |
|---------|-------------|
| `/novo_projeto` | Início do projeto — cria estrutura e templates |
| `/iniciar_desev_qlik` | Após preencher templates — gera scripts e mockup |
| `/Documentar_Desev._Qlik` | Após validação — gera documentação final |
| `/avaliar_skill` | Para avaliar e melhorar um skill |

## Fluxo do projeto
1. Git clone do repositório
2. `/novo_projeto` — estrutura + templates
3. Preencher templates com usuário de negócio
4. `/iniciar_desev_qlik` — scripts + mockup + validação
5. Apresentar ao usuário e coletar feedbacks
6. `/Documentar_Desev._Qlik` — documentação final
7. Git push e entrega

## MCPs configurados
- **Figma** — mockup de alta fidelidade
  * Configurar via: `claude mcp add --transport http figma-remote-mcp https://mcp.figma.com/mcp`
  * Autenticação: OAuth via `/mcp`
  * Documentação: `.claude/docs/configuracao_figma_mcp.md`
- **Excalidraw** — wireframe fallback

## Arquivos de configuração
- `.claude/settings.local.json` — permissões (nunca versionar)
- `.claude/settings.json` — configurações (nunca versionar)
- `requirements.txt` — dependências Python

## Importante
- NUNCA versionar `settings.json` ou `settings.local.json`
- NUNCA expor tokens do Figma em arquivos
- SEMPRE usar OAuth para autenticação Figma