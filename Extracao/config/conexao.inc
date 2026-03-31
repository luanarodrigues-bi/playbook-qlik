// =============================================================================
// conexao.inc — Configuração de Conexão
// Fonte: ERP Protheus (SQL Server)
// Ajuste as credenciais antes de usar em produção.
// =============================================================================

// -----------------------------------------------------------------------------
// Conexão principal — ERP Protheus (SQL Server via ODBC)
// Preencha: SERVER, DATABASE, UID e PWD antes do primeiro uso
// -----------------------------------------------------------------------------
LIB CONNECT TO 'Protheus_SQLServer';

/*
   Alternativa via string direta (QlikView / Sense Desktop):

   OLEDB CONNECT32 TO
       [Provider=SQLOLEDB.1;
        Persist Security Info=False;
        User ID=<SEU_USUARIO>;
        Initial Catalog=<NOME_DO_BANCO>;
        Data Source=<SERVIDOR_OU_IP>;
        Use Procedure for Prepare=1;
        Auto Translate=True;
        Packet Size=4096;
        Workstation ID=WORKSTATION;
        Use Encryption for Data=False;
        Tag with column collation when possible=False]
       (XPassword is '<SENHA_CRIPTOGRAFADA>');
*/
