// =============================================================================
// main_transform.inc — Orquestrador de Transformação
// Projeto: Performance Comercial
//
// ORDEM DE EXECUÇÃO OBRIGATÓRIA:
//   1. Faturamento  — gera fato_vendas_final e resumo_faturamento_mensal
//   2. Financeiro   — consome fato_vendas como referência; gera dim_cliente_enriched
//   3. Metas        — consome resumo_faturamento_mensal; gera fato_metas_enriched
//
// Pré-requisito: executar main_load.inc (Extracao) antes desta etapa.
//
// Como usar:
//   Cole no Script principal do app Qlik Sense após o bloco de extração,
//   ou referencie via $(Must_Include=[lib://DataFiles/Transformacao/main_transform.inc]);
// =============================================================================

// ─── Etapa 1: Faturamento ─────────────────────────────────────────────────────
// Entrada : fato_vendas.qvd · dim_tempo.qvd · dim_consultor.qvd · dim_produto.qvd
// Saída   : fato_vendas_final.qvd · resumo_faturamento_mensal.qvd

$(Must_Include=[lib://DataFiles/Transformacao/01_transform_faturamento.inc]);

// ─── Etapa 2: Financeiro ──────────────────────────────────────────────────────
// Entrada : fato_financeiro.qvd · dim_cliente.qvd · dim_tempo.qvd · fato_vendas.qvd
// Saída   : fato_financeiro_enriched.qvd · resumo_inadimplencia.qvd · dim_cliente_enriched.qvd

$(Must_Include=[lib://DataFiles/Transformacao/02_transform_financeiro.inc]);

// ─── Etapa 3: Metas ───────────────────────────────────────────────────────────
// Entrada : fato_metas.qvd · dim_consultor.qvd · resumo_faturamento_mensal.qvd
// Saída   : fato_metas_enriched.qvd · resumo_metas_gerencia.qvd

$(Must_Include=[lib://DataFiles/Transformacao/03_transform_metas.inc]);

// =============================================================================
// QVDs transformados disponíveis em: lib://DataFiles/Transformacao/QVDs/
//
//   fato_vendas_final.qvd          — Fato vendas enriquecido com flags e contexto
//   resumo_faturamento_mensal.qvd  — Agrupado por consultor/mês (suporte MoM/YoY)
//   fato_financeiro_enriched.qvd   — Fato financeiro com Dias_Atraso e flags
//   resumo_inadimplencia.qvd       — Inadimplência agregada por cliente/mês
//   dim_cliente_enriched.qvd       — Dimensão cliente com Ativo/Novo/Inativo
//   fato_metas_enriched.qvd        — Metas com realizado e % atingimento
//   resumo_metas_gerencia.qvd      — Metas agregadas por gerência/mês
// =============================================================================
