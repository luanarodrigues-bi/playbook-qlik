# Relatório de Validação Técnica — Performance Comercial

**Projeto:** Monitoramento de Performance Comercial
**Data da validação:** 2026-03-31 (atualizado)
**Fonte de dados:** ERP Protheus (SQL Server)
**Responsável técnico:** Claude Code (revisão automatizada)
**Pastas avaliadas:** `Extracao/` · `Transformacao/` · `App/`
**Checklist base:** `04_Checklist_Validacao.xlsx` (última atualização: 2026-03-31)

---

## 1. Tabela de Validação

> Status conforme preenchimento do analista no `04_Checklist_Validacao.xlsx`.

| # | Fase | Item de Verificação | Status Checklist | Avaliação Técnica | Justificativa |
|---|---|---|---|---|---|
| 1 | Extração | Conexão com a fonte de dados validada | **Parcial** | Parcial | `Extracao/config/conexao.inc` declara `LIB CONNECT TO 'Protheus_SQLServer'` com alternativa OLEDB comentada. Arquivo correto, mas credenciais reais do SQL Server ainda não foram validadas em ambiente de produção conforme nota do analista. |
| 2 | Extração | Volume de registros conferido com a origem | **Pendente** | Gap | Nenhum script `.inc` registra contagem de linhas extraídas (`NoOfRows`, `TRACE`) nem compara com a origem. Script `99_validacao_volume.inc` ainda não criado. |
| 3 | Extração | Campos nulos/ausentes identificados e tratados | **OK** | OK | Todos os 7 scripts de extração aplicam `ISNULL()` em campos críticos: valores numéricos → `0`, textos → `'NAO INFORMADO'`, FKs → `0`. Tipos respeitam o Data Request (DECIMAL, DATE, VARCHAR). |
| 4 | Transformação | Regras de negócio aplicadas corretamente | **OK** | OK | As 3 transformações cobrem os 20 indicadores da Biblioteca: `01_transform_faturamento.inc` (11 indicadores), `02_transform_financeiro.inc` (5), `03_transform_metas.inc` (3 + Ticket Médio compartilhado). Fórmulas conferem com a Biblioteca de Indicadores. |
| 5 | Transformação | Joins e relacionamentos validados | **OK** | OK | Transformações usam `ApplyMap` / `MAPPING LOAD` em vez de `JOIN`, padrão recomendado no Qlik para evitar loops e chaves sintéticas. Relacionamentos do modelo estrela corretos conforme `modelo_dados.md`. |
| 6 | Transformação | Duplicatas verificadas e tratadas | **OK** | OK | `GROUP BY` aplicado nas tabelas de resumo (`resumo_faturamento_mensal`, `resumo_financeiro_mensal`, `resumo_metas_mensal`). Unicidade garantida pela chave primária nas queries SQL de origem. |
| 7 | Transformação | Tipos de dados corretos (datas, números, texto) | **OK** | OK | `Date#(Text(ID_Data), 'YYYYMMDD')` para conversão de datas; `DECIMAL(18,2)` nos valores monetários; `VARCHAR` nos campos texto; `ID_Data` como `INTEGER YYYYMMDD` para join eficiente com `dim_tempo`. |
| 8 | App Qlik | Modelo de dados sem chaves sintéticas | **OK** | OK | Arquitetura usa `ApplyMap` para enriquecer `fato_vendas` com atributos de dimensão sem criar JOINs adicionais. Modelo estrela projetado sem loops. Validação no Data Model Viewer do Qlik Sense pendente de construção do app. |
| 9 | App Qlik | Indicadores conferidos com planilha de referência | **Parcial** | Parcial | `App/storytelling.md` documenta todos os 20 indicadores com Set Analysis, tipo de visualização e justificativa. Conferência com dados reais do ERP Protheus pendente (app ainda não construído). |
| 10 | App Qlik | Filtros e seleções funcionando corretamente | **Pendente** | Gap | Filtros globais (Período, Região, UF, Consultor, Linha de Produto, Canal) especificados no `storytelling.md` por sheet. Validação real depende da construção e teste do app Qlik Sense. |
| 11 | App Qlik | Gráficos e tabelas exibindo dados corretos | **Pendente** | Gap | Tipo de visualização, dimensões, medidas e Set Analysis especificados para cada objeto em `storytelling.md`. Validação visual pendente de construção do app. |
| 12 | App Qlik | Performance de carregamento aceitável | **Pendente** | Gap | Arquitetura QVD em duas camadas garante carregamento incremental. Índices recomendados no DDL para FKs das tabelas fato. Teste real pendente de carga com dados do SQL Server. |
| 13 | Entrega | Validação com usuário de negócio concluída | **Pendente** | Gap | Sessão UAT com Gerente Comercial ainda não realizada. `App/roteiro_validacao_usuario.md` gerado como subsídio para essa sessão. |
| 14 | Entrega | Documentação atualizada | **Pendente** | Parcial | `modelo_dados.md`, `ddl_modelo_estrela.sql`, scripts comentados e `storytelling.md` gerados e completos. `relatorio_validacao.md` atualizado. Falta documentação final pós-go-live (ata de validação, matriz de acesso). |
| 15 | Entrega | Acesso de usuários configurado no Qlik Cloud | **Pendente** | Gap | `storytelling.md` documenta a lógica de Section Access (Consultor → próprios dados, Gerente → região, Diretor → tudo). Configuração real no Qlik Cloud Management Console pendente de implantação do app. |

---

## 2. Gaps Encontrados e Sugestões de Correção

### Gap 1 — Validação de credenciais de conexão (Item 1 — Parcial)

**Problema:** `conexao.inc` está tecnicamente correto, mas as credenciais reais do SQL Server local ainda não foram testadas.

**Sugestão de correção:**
1. Abrir o Qlik Sense Desktop/Server e criar a Data Connection `Protheus_SQLServer` apontando para o servidor real
2. Executar um `SELECT TOP 1` de cada tabela para confirmar acesso
3. Atualizar o item 1 do checklist para OK após confirmação

---

### Gap 2 — Verificação de volume de registros (Item 2 — Pendente)

**Problema:** Os scripts de extração não registram a quantidade de linhas extraídas nem comparam com a origem.

**Sugestão de correção:** Adicionar ao final de cada `.inc` de extração:

```qlik
LET vQtd = NoOfRows('dim_cliente');
TRACE === dim_cliente: $(vQtd) registros extraídos ===;
```

Criar `Extracao/99_validacao_volume.inc` para reconciliação com a origem:

```qlik
temp_contagem_origem:
LOAD Tabela, Qtd_Origem;
SELECT 'fato_vendas' AS Tabela, COUNT(*) AS Qtd_Origem
FROM dbo.Pedidos
WHERE DataEmissao BETWEEN '$(vDataInicioSQL)' AND '$(vDataFimSQL)';
```

---

### Gap 3 — Construção e teste do App Qlik Sense (Itens 10, 11, 12 — Pendente)

**Problema:** Filtros, gráficos e performance só podem ser validados com o app construído no Qlik Sense.

**Sugestão de correção:**
1. Usar `App/storytelling.md` como especificação para construir as 4 sheets no Qlik Sense
2. Carregar os QVDs da camada de Transformação
3. Testar cada filtro e cada objeto visual com dados reais
4. Medir tempo de reload no Qlik Cloud após carga completa

---

### Gap 4 — Validação com usuário de negócio (Item 13 — Pendente)

**Problema:** Sessão UAT com Gerente Comercial e Analista de BI ainda não realizada.

**Sugestão de correção:**
1. Usar `App/roteiro_validacao_usuario.md` como guia da sessão
2. Validar cada indicador com dados reais do ERP Protheus
3. Registrar aprovações e ajustes na ata de validação

---

### Gap 5 — Documentação final e acesso no Qlik Cloud (Itens 14, 15 — Pendente)

**Problema:** Documentação pós-go-live e Section Access no Qlik Cloud ainda pendentes.

**Sugestão de correção:**
1. Após validação com usuário, criar `Documentacao/ata_validacao_negocio.md`
2. No Qlik Cloud Management Console: criar grupos `DIRETORES`, `GERENTES_REGIONAIS`, `CONSULTORES`
3. Implementar o Section Access documentado em `App/storytelling.md`
4. Testar com usuário de cada perfil antes do go-live

---

## 3. Nota Final

### Pontuação por item (baseada no checklist atualizado em 2026-03-31)

| Status | Peso | Qtd Itens | Itens | Subtotal |
|---|---|---|---|---|
| OK | 1,0 | 6 | 3, 4, 5, 6, 7, 8 | 6,0 |
| Parcial | 0,5 | 3 | 1, 9, 14 | 1,5 |
| Pendente / Gap | 0,0 | 6 | 2, 10, 11, 12, 13, 15 | 0,0 |
| **Total** | | **15** | | **7,5 / 15** |

### **Nota: 5,0 / 10**

**Justificativa:**

A nota reflete o estado **real** do projeto: a camada técnica de **extração e transformação** está sólida e completa (6 itens OK), mas a fase de **construção do app e validação com o negócio** ainda não foi realizada. Os 6 itens Pendente são etapas de processo que dependem da implantação do app Qlik Sense no ambiente real.

A redução em relação à avaliação anterior (7,5 → 5,0) reflete a atualização do checklist pelo analista, que marcou como Pendente itens que antes eram considerados parcialmente validados via documentação. Essa é uma avaliação mais conservadora e correta.

**Roadmap para atingir nota 9+:**

| Prioridade | Ação | Impacto na nota |
|---|---|---|
| 1 | Validar credenciais de conexão no SQL Server real | +0,5 (item 1 Parcial → OK) |
| 2 | Construir app Qlik Sense (4 sheets) e testar filtros/gráficos | +2,0 (itens 10, 11 Pendente → OK) |
| 3 | Realizar teste de performance com carga real | +0,5 (item 12 Pendente → OK) |
| 4 | Realizar sessão UAT com Gerente Comercial | +0,5 (item 13 Pendente → OK) |
| 5 | Finalizar documentação pós-go-live e Section Access | +1,0 (itens 14, 15 Pendente → OK) |
| 6 | Criar script de validação de volume | +0,5 (item 2 Pendente → OK) |
| **Total potencial** | | **+5,0 → nota 10,0** |
