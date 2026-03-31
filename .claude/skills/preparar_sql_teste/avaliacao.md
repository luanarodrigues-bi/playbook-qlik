# Avaliação do Skill: preparar_sql_teste

**Data:** 2026-03-31
**Avaliador:** Claude Code (auto-avaliação pós-execução)
**Projeto avaliado:** Performance Comercial — playbook_qlik

---

## Tabela de Pontuação

| Critério | Nota | Justificativa |
|---|---|---|
| 1. Aderência ao Padrão BIX | 8/10 | Formatos corretos (.sql, .xlsx), pastas corretas, nomenclatura sequencial, dependências instaladas. Perde por não instruir verificação de idempotência. |
| 2. Qualidade Técnica SQL | 7/10 | T-SQL correto, distribuições realistas, FK + índices, validação de integridade referencial. Perde pela abordagem convoluta no ID_Data do fato_vendas (INSERT com NEWID() fixo + UPDATE posterior). |
| 3. Inteligência Adaptativa | 5/10 | Claude leu os templates antes de gerar. Mas o skill não instrui explicitamente a verificar se os scripts já existem — a checagem foi por iniciativa do Claude, não por instrução do skill. |
| 4. Completude | 9/10 | Todos os 5 entregáveis gerados: 4 scripts SQL + kpis_esperados.xlsx. Instruções de execução claras, KPIs documentados, próximo passo informado. |
| 5. Erros Comuns | 4/10 | Skill não documenta nenhum erro esperado. Na execução real ocorreram: (a) heredoc EOF inesperado no bash Windows, (b) Write tool falhou sem leitura prévia, (c) primeira tentativa do kpis_esperados.xlsx foi interrompida pelo usuário. |

**Nota Final: 6,6 / 10**

---

## O que está bom

- Estrutura de 5 passos clara e sequencial
- Parâmetros de dados bem definidos (70/20/10, 80/15/5, ±10%)
- Instrução de instalar dependências antes de gerar
- kpis_esperados.xlsx com tolerâncias documentadas
- 04_validar_volumes.sql vai além do COUNT — inclui KPIs e integridade referencial
- Nomenclatura sequencial facilita execução ordenada

## O que precisa melhorar

### Problema 1 — Sem idempotência explícita (impacto: ALTO)
O skill não instrui Claude a verificar se os scripts já existem antes de recriar.
Na segunda execução, Claude verificou por conta própria — mas o comportamento
deveria ser garantido pelo skill, não depender do julgamento do modelo.

**Correção:** Adicionar instrução explícita: "Antes de criar cada arquivo, verifique se
já existe. Se existir e o DDL/Data Request não mudou, pule e informe."

### Problema 2 — Sem documentação de erros comuns no Windows (impacto: ALTO)
Bash heredoc (`<< 'EOF'`) falha silenciosamente no Git Bash / Windows quando o
script Python contém caracteres especiais (aspas simples, acentos). A tentativa
com heredoc gerou `unexpected EOF` e interrompeu a execução.

**Correção:** Instruir explicitamente a usar a ferramenta `Write` para criar scripts
Python temporários, nunca heredoc no bash.

### Problema 3 — Abordagem convoluta no ID_Data do fato_vendas (impacto: MÉDIO)
O 03_popular_fatos.sql insere todos os pedidos com o mesmo ID_Data (via COALESCE
+ SELECT TOP 1 ORDER BY NEWID()) e depois faz um UPDATE geral para distribuir as
datas. Isso funciona mas é difícil de debugar e viola a expectativa de
"distribuição nos 24 meses" descrita no skill.

**Correção:** Documentar essa limitação técnica no skill e sugerir ao avaliador
rodar o 04_validar_volumes.sql para confirmar que as datas ficaram distribuídas.

### Problema 4 — kpis_esperados.xlsx sem fórmulas dinâmicas (impacto: BAIXO)
Os KPIs são valores fixos calculados manualmente. Se o usuário alterar os
parâmetros (ex: 6.000 pedidos), os valores esperados ficam desatualizados.

**Correção:** Mencionar no skill que os valores são estimativas estáticas — o
04_validar_volumes.sql é a fonte de verdade dos KPIs reais.

---

## Top 3 Melhorias Aplicadas no SKILL_melhorado.md

1. **Idempotência explícita** — instrução para verificar existência antes de criar
2. **Uso de Write tool** em vez de heredoc para scripts Python temporários
3. **Seção de Erros Comuns** com os problemas conhecidos e suas correções
