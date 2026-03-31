Leia os arquivos do projeto para entender a estrutura de dados:
- Documentacao/02_Biblioteca_Indicadores.xlsx
- Documentacao/03_Data_Request.xlsx
- Extracao/ddl_modelo_estrela.sql

Com base nesses arquivos, gere scripts SQL para popular o banco local
com dados fictícios realistas.

---

## ANTES DE GERAR QUALQUER ARQUIVO

1. Instale as dependências Python:
   pip install openpyxl -q --user

2. Para cada arquivo listado abaixo, verifique se já existe:
   - Se existir E o DDL/Data Request não mudou desde a geração: PULE e informe.
   - Se não existir OU houve mudança relevante nos templates: gere ou atualize.

3. Para criar scripts Python temporários, use SEMPRE a ferramenta Write —
   NUNCA use heredoc no bash (causa erro EOF inesperado no Windows).
   Após executar o script Python, apague-o com: rm arquivo.py

---

## 1. Criar banco de dados local

Gerar `Extracao/sql_teste/01_criar_banco.sql`:
- Verificar se o banco já existe antes de criar (IF NOT EXISTS)
- Criar banco `performance_comercial` com COLLATE Latin1_General_CI_AI
- Criar todas as tabelas (idempotente — DROP + CREATE):
  - dim_tempo, dim_cliente, dim_consultor, dim_produto
  - fato_vendas, fato_financeiro, fato_metas
- FK constraints entre fatos e dimensões
- Índices de performance nos campos de join

---

## 2. Popular dimensões

Gerar `Extracao/sql_teste/02_popular_dimensoes.sql`:
- dim_tempo — calendário dos últimos 24 meses via WHILE loop (T-SQL)
  * ID_Data no formato YYYYMMDD como INT
  * Flag_Fim_Semana = 1 para sábado/domingo
- dim_cliente — 50 clientes com nomes reais brasileiros de empresas
- dim_consultor — 10 consultores com hierarquia:
  * 2 Diretorias → 4 Gerências → 10 Consultores
  * Campos: ID_Consultor, Nome_Consultor, Gerencia_Regional, Regiao, UF
- dim_produto — 20 produtos em 4 linhas de produto

---

## 3. Popular fatos

Gerar `Extracao/sql_teste/03_popular_fatos.sql`:

### fato_vendas — 5.000 pedidos distribuídos nos 24 meses
- Valores entre R$ 1.000 e R$ 50.000
- Mix de status: 70% Fechado, 20% Aberto, 10% Cancelado
- Mix de canais: 50% Direto, 35% Distribuidor, 15% E-commerce
- Descontos entre 0% e 15%
- Distribuição regional: 40% Sul, 60% Sudeste
- Usar CHECKSUM(NEWID()) + ABS + % para aleatoriedade determinista
- Usar CROSS APPLY para atribuir ID_Data válido da dim_tempo a cada pedido

### fato_financeiro — títulos baseados nos pedidos Fechados
- 1 título por pedido Fechado
- 80% Pago (pagamento até 25 dias após vencimento)
- 15% Atrasado (pagamento 5–45 dias após vencimento)
- 5% Inadimplente (sem pagamento — Valor_Em_Atraso = Valor_Total)
- Vencimento: 30 dias após a data da venda

### fato_metas — metas mensais por consultor
- 1 linha por consultor por mês (10 × 24 = 240 linhas)
- Meta base: R$ 80.000/mês
- Crescimento acumulado de 5% ao mês
- Variação por consultor: ±10% baseado no ID

---

## 4. Validar volumes

Gerar `Extracao/sql_teste/04_validar_volumes.sql`:
- COUNT por tabela em uma única query (UNION ALL)
- Distribuição de status e canal em fato_vendas (com %)
- KPIs financeiros: faturamento, ticket médio, taxa de conversão
- KPIs financeiro: inadimplência em valor e percentual
- KPIs metas: meta total, média por consultor
- Atingimento de meta nos últimos 3 meses por consultor
- Verificação de integridade referencial (Orphans deve ser 0 em todos)

---

## 5. Gerar KPIs esperados

Usar a ferramenta Write para criar um script Python temporário `gerar_kpis.py`
e executá-lo com `python gerar_kpis.py`, depois apagá-lo com `rm gerar_kpis.py`.

Gerar `Status/kpis_esperados.xlsx` com 2 abas:

**Aba 1 — KPIs Esperados:**
- Tabela com: KPI | Categoria | Valor Esperado | Unidade | Tolerância | Observação
- Cabeçalho azul escuro, linhas alternadas por categoria
- KPIs obrigatórios (com tolerâncias):
  * Faturamento Total ≈ R$ 82,5M (±15%)
  * Ticket Médio ≈ R$ 23.587 (±10%)
  * Total de Pedidos = 5.000 (exato)
  * Taxa de Conversão ≈ 87,5% (±3pp)
  * % Inadimplência ≈ 5% (±2pp)
  * Linhas de Meta = 240 (exato)
  * % Atingimento de Meta ≈ 31% (±10pp)

**Aba 2 — Como Validar no Qlik:**
- Roteiro de 12 passos: do SQL ao Qlik
- Critério de aprovação para cada passo

---

## ERROS COMUNS E SOLUÇÕES

| Erro | Causa | Solução |
|---|---|---|
| `unexpected EOF while looking for matching` | Heredoc no bash com aspas simples no código Python | Usar ferramenta Write para criar o .py, não heredoc |
| `Write tool: file not read first` | Write tool exige leitura prévia para arquivos existentes | Usar Read antes de Write em arquivos existentes |
| `LEAST is not a recognized function` | SQL Server < 2022 não tem LEAST() | Substituir por `CASE WHEN a < b THEN a ELSE b END` |
| `openpyxl not found` | Dependência não instalada | `pip install openpyxl -q --user` antes de rodar o .py |
| Todos os pedidos com a mesma data | SELECT TOP 1 ORDER BY NEWID() no INSERT retorna valor fixo por batch | Usar CROSS APPLY para atribuir ID_Data determinístico por pedido |

---

## SAÍDA ESPERADA

Ao final, informe ao usuário:

1. **Scripts gerados** (caminho de cada arquivo)
2. **Como executar** no SSMS ou Azure Data Studio:
   - Conectar com permissão CREATE DATABASE
   - Executar na ordem: 01 → 02 → 03 → 04
3. **KPIs esperados** em tabela resumida com tolerâncias
4. **Próximo passo:** rodar `Extracao/main_load.inc` no Qlik Desktop e comparar
   os valores do app com `Status/kpis_esperados.xlsx`
