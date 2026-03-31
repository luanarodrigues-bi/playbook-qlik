# Roteiro de Validação com Usuário de Negócio — Performance Comercial

**Projeto:** Monitoramento de Performance Comercial
**Versão:** 1.0 | **Data:** 2026-03-31
**Facilitador:** Analista de BI
**Validadores:** Gerente Comercial · Analista de BI
**Duração estimada da sessão:** 90 minutos

---

## 1. Objetivo da Sessão

Confirmar com os usuários de negócio que:
1. Os **20 indicadores** estão calculados conforme a regra de negócio esperada
2. Os **filtros** e **dimensões de análise** cobrem as necessidades operacionais
3. As **metas** carregadas na base refletem os valores reais
4. Não há indicadores faltando ou calculados de forma errada

---

## 2. Preparação (Analista de BI — antes da reunião)

- [ ] App Qlik Sense carregado com dados reais do ERP Protheus
- [ ] Período de dados disponível: últimos 24 meses
- [ ] Planilha de metas importada e validada na tabela `fato_metas`
- [ ] Comparativo de referência: relatório Excel atual do analista (base de comparação)
- [ ] Acesso de demonstração configurado com perfil de Gerente Comercial

---

## 3. Roteiro de Apresentação

### Bloco 1 — Contexto (5 min)

> "Vamos apresentar o resultado do desenvolvimento do painel de Performance Comercial.
> O objetivo desta sessão é validar se os números que o sistema está mostrando
> batem com o que vocês conhecem do negócio. Para cada indicador, vamos comparar
> o valor do painel com a referência que vocês têm — seja o Excel, o relatório do ERP
> ou o conhecimento do período."

---

### Bloco 2 — Visão Executiva: Sheet 01 (20 min)

**Filtro de teste:** Selecionar mês fechado mais recente (ex.: fevereiro/2026)

#### Indicadores a validar:

| # | Indicador | Regra de Cálculo Aplicada | Valor no Painel | Valor de Referência | Validado? | Observação |
|---|---|---|---|---|---|---|
| 1 | Faturamento Realizado | `SUM(Valor_Venda)` — valor líquido após descontos | | | ☐ Sim ☐ Não ☐ Ajuste | |
| 2 | Meta de Faturamento | `SUM(Valor_Meta)` — planilha de metas do mês | | | ☐ Sim ☐ Não ☐ Ajuste | |
| 3 | % Atingimento de Meta | `Faturamento / Meta` — meta mensal por consultor | | | ☐ Sim ☐ Não ☐ Ajuste | |
| 12 | Crescimento MoM | `(Mês Atual - Mês Anterior) / Mês Anterior` | | | ☐ Sim ☐ Não ☐ Ajuste | |
| 13 | Crescimento YoY | `(Ano Atual - Ano Anterior) / Ano Anterior` | | | ☐ Sim ☐ Não ☐ Ajuste | |
| 7 | Qtd de Pedidos | `COUNT(ID_Pedido)` — todos os pedidos do período | | | ☐ Sim ☐ Não ☐ Ajuste | |

**Perguntas-chave:**
- O faturamento bate com o fechamento do mês no ERP?
- A meta carregada é a meta oficial definida no início do mês?
- O crescimento MoM/YoY está na mesma direção que a percepção do time?

---

### Bloco 3 — Performance por Consultor e Região: Sheet 02 (25 min)

**Filtro de teste:** Selecionar gerência regional específica + mês fechado

#### Indicadores a validar:

| # | Indicador | Regra de Cálculo Aplicada | Valor no Painel | Valor de Referência | Validado? | Observação |
|---|---|---|---|---|---|---|
| 8 | Faturamento por Região | `SUM(Valor_Venda) GROUP BY Regiao` | | | ☐ Sim ☐ Não ☐ Ajuste | |
| 9 | Faturamento por Consultor | `SUM(Valor_Venda) GROUP BY Consultor` | | | ☐ Sim ☐ Não ☐ Ajuste | |
| 3 | % Atingimento por Consultor | `SUM(Valor_Venda) / SUM(Valor_Meta)` por consultor | | | ☐ Sim ☐ Não ☐ Ajuste | |
| 4 | Ticket Médio | `SUM(Valor_Venda) / COUNT(Pedidos)` | | | ☐ Sim ☐ Não ☐ Ajuste | |
| 5 | Taxa de Conversão | `COUNT(Pedidos Fechados) / COUNT(Total Pedidos)` | | | ☐ Sim ☐ Não ☐ Ajuste | |

**Perguntas-chave:**
- A hierarquia Gerência Regional > Consultor está correta?
- Algum consultor aparece em região errada?
- A taxa de conversão faz sentido com a percepção do time de vendas?
- O filtro por UF está funcionando conforme esperado?

---

### Bloco 4 — Análise de Produtos e Canal: Sheet 03 (15 min)

**Filtro de teste:** Selecionar linha de produto + canal de venda específico

#### Indicadores a validar:

| # | Indicador | Regra de Cálculo Aplicada | Valor no Painel | Valor de Referência | Validado? | Observação |
|---|---|---|---|---|---|---|
| 10 | Faturamento por Produto | `SUM(Valor_Venda) GROUP BY Produto` | | | ☐ Sim ☐ Não ☐ Ajuste | |
| 11 | Faturamento por Canal | `SUM(Valor_Venda) GROUP BY Canal_Venda` | | | ☐ Sim ☐ Não ☐ Ajuste | |
| 19 | % Desconto Médio | `SUM(Valor_Desconto) / SUM(Valor_Bruto)` | | | ☐ Sim ☐ Não ☐ Ajuste | |
| 20 | Margem de Contribuição | `SUM(Valor_Venda - Custo) / SUM(Valor_Venda)` | | | ☐ Sim ☐ Não ☐ Ajuste | |
| 18 | Valor Médio por Pedido | `SUM(Valor_Venda) / COUNT(ID_Pedido)` | | | ☐ Sim ☐ Não ☐ Ajuste | |

**Perguntas-chave:**
- Os canais de venda (Direto, Distribuidor, E-commerce) batem com os da operação?
- As linhas de produto estão agrupadas corretamente?
- O % de desconto está dentro ou fora da meta de < 10%?
- A margem de contribuição faz sentido para a categoria de produto?

---

### Bloco 5 — Financeiro e Base de Clientes: Sheet 04 (15 min)

**Filtro de teste:** Período dos últimos 3 meses

#### Indicadores a validar:

| # | Indicador | Regra de Cálculo Aplicada | Valor no Painel | Valor de Referência | Validado? | Observação |
|---|---|---|---|---|---|---|
| 6 | Inadimplência | `SUM(Valor_Em_Atraso) / SUM(Valor_Total)` | | | ☐ Sim ☐ Não ☐ Ajuste | |
| 17 | Prazo Médio de Pagamento | `AVG(Data_Pagamento - Data_Vencimento)` | | | ☐ Sim ☐ Não ☐ Ajuste | |
| 14 | Qtd Clientes Ativos | `COUNT(DISTINCT ID_Cliente com Valor_Venda > 0)` | | | ☐ Sim ☐ Não ☐ Ajuste | |
| 15 | Novos Clientes | `COUNT(clientes cuja 1ª compra foi no mês atual)` | | | ☐ Sim ☐ Não ☐ Ajuste | |
| 16 | Clientes Inativos | `COUNT(última compra há mais de 90 dias)` | | | ☐ Sim ☐ Não ☐ Ajuste | |

**Perguntas-chave:**
- A inadimplência calculada bate com os dados do financeiro?
- O prazo médio de pagamento está alinhado com o que o time espera?
- A definição de "cliente inativo" (90 dias sem compra) faz sentido para o negócio?
- Existe algum cliente grande que aparece como inativo mas não deveria?

---

## 4. Confirmação de Regras de Negócio

As questões abaixo têm resposta pendente de confirmação com o usuário:

| # | Pergunta | Regra Atual Implementada | Confirmado? | Ajuste Necessário |
|---|---|---|---|---|
| R1 | Valor_Venda é líquido (após desconto) ou bruto? | Líquido (`ValorLiquido` do Protheus) | ☐ Sim ☐ Não | |
| R2 | A meta é por consultor/mês ou por equipe/mês? | Por consultor/mês (`dbo.Metas`) | ☐ Sim ☐ Não | |
| R3 | "Clientes inativos" = sem compra há > 90 dias. Correto? | 90 dias corridos | ☐ Sim ☐ Não | |
| R4 | Status "Fechado" é o único status que conta como venda? | Sim (filtro `Status_Pedido = 'FECHADO'`) | ☐ Sim ☐ Não | |
| R5 | A taxa de conversão usa oportunidades ou pedidos abertos? | `COUNT(Fechados) / COUNT(Total Pedidos)` | ☐ Sim ☐ Não | |
| R6 | Custo_Produto inclui frete/impostos ou é só custo direto? | Custo direto do produto (`CustoProduto`) | ☐ Sim ☐ Não | |
| R7 | O refresh diário às 6h substitui o Excel semanal completamente? | Sim — automático no Qlik Cloud | ☐ Sim ☐ Não | |

---

## 5. Controle de Ajustes Identificados

| # | Indicador/Tela | Ajuste Solicitado | Prioridade | Responsável | Status |
|---|---|---|---|---|---|
| | | | | | |
| | | | | | |
| | | | | | |

---

## 6. Checklist de Encerramento da Sessão

- [ ] Todos os 20 indicadores passaram pela validação
- [ ] Ajustes identificados registrados na tabela de controle acima
- [ ] Regras de negócio ambíguas confirmadas (seção 4)
- [ ] Próximos passos definidos com responsáveis e datas
- [ ] Usuário assinou (ou aprovou por e-mail) os indicadores validados

---

## 7. Encaminhamentos Pós-Sessão

| Ação | Responsável | Prazo |
|---|---|---|
| Corrigir ajustes identificados na sessão | Analista de BI | — |
| Revalidar indicadores ajustados | Gerente Comercial | — |
| Configurar Section Access (perfis de acesso) | Analista de BI | — |
| Publicar app em produção no Qlik Cloud | Analista de BI | — |
| Treinar usuários finais | Analista de BI | — |
| Comunicar go-live para equipe | Gerente Comercial | — |

---

> **Nota:** Este roteiro foi gerado automaticamente com base na `02_Biblioteca_Indicadores.xlsx` e no `Documentacao/relatorio_validacao.md`. Preencha os campos de valor de referência antes da reunião consultando o relatório Excel semanal atual.
