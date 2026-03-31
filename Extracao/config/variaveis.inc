// =============================================================================
// variaveis.inc — Variáveis globais do projeto
// Projeto: Performance Comercial | Fonte: ERP Protheus
// =============================================================================

// -----------------------------------------------------------------------------
// Janela de dados históricos (24 meses conforme levantamento de requisitos)
// -----------------------------------------------------------------------------
LET vDataFim    = Today();
LET vDataInicio = AddMonths(Today(), -24);

// Formatos auxiliares para uso em SQL (YYYY-MM-DD)
LET vDataInicioSQL = Date(vDataInicio, 'YYYY-MM-DD');
LET vDataFimSQL    = Date(vDataFim,    'YYYY-MM-DD');

// -----------------------------------------------------------------------------
// Refresh — Diário às 06:00h (conforme levantamento de requisitos)
// Usado para documentação; o agendamento real é feito no Qlik Cloud Management
// -----------------------------------------------------------------------------
LET vRefresh = '06:00';

// -----------------------------------------------------------------------------
// Caminhos de armazenamento
// -----------------------------------------------------------------------------
// Qlik Cloud (Data Files):
LET vPathQVD = 'lib://DataFiles/QVDs/';

// Alternativa para Qlik Sense Server / Desktop (ajuste o caminho físico):
// LET vPathQVD = 'C:\playbook_qlik\Extracao\QVDs\';

// -----------------------------------------------------------------------------
// Metadados do projeto
// -----------------------------------------------------------------------------
LET vNomeProjeto   = 'Performance Comercial';
LET vVersao        = '1.0';
LET vDataGeracao   = Now();
