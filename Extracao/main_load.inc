// =============================================================================
// main_load.inc — Orquestrador de Extração
// Projeto: Performance Comercial
// Executa todos os scripts de extração em ordem:
//   1. Dimensões (clientes, consultores, produtos, tempo)
//   2. Fatos (vendas, financeiro, metas)
//
// Como usar:
//   Cole o conteúdo abaixo no Script principal do app Qlik Sense,
//   ou referencie via $(Must_Include=[lib://DataFiles/Extracao/main_load.inc]);
// =============================================================================

// ─── Dimensões ───────────────────────────────────────────────────────────────

$(Must_Include=[lib://DataFiles/Extracao/01_extract_dim_cliente.inc]);

$(Must_Include=[lib://DataFiles/Extracao/02_extract_dim_consultor.inc]);

$(Must_Include=[lib://DataFiles/Extracao/03_extract_dim_produto.inc]);

$(Must_Include=[lib://DataFiles/Extracao/04_extract_dim_tempo.inc]);

// ─── Fatos ───────────────────────────────────────────────────────────────────

$(Must_Include=[lib://DataFiles/Extracao/05_extract_fato_vendas.inc]);

$(Must_Include=[lib://DataFiles/Extracao/06_extract_fato_financeiro.inc]);

$(Must_Include=[lib://DataFiles/Extracao/07_extract_fato_metas.inc]);

// =============================================================================
// Fim da extração — QVDs gerados em: $(vPathQVD)
// =============================================================================
