Leia os arquivos do projeto para entender o contexto atual:
- Documentacao/01_Levantamento_Requisitos.xlsx
- Documentacao/02_Biblioteca_Indicadores.xlsx
- Documentacao/03_Data_Request.xlsx
- App/roteiro_validacao_usuario.md
- App/storytelling.md
- Documentacao/relatorio_validacao.xlsx

O usuário vai colar abaixo os feedbacks coletados na sessão
de validação com o usuário de negócio.

$FEEDBACK

Com base nos feedbacks informados:

1. Analise cada feedback e classifique:
   - Tipo: Correção de cálculo / Novo indicador / Ajuste visual /
     Regra de negócio / Filtro / Outro
   - Impacto: Alto / Médio / Baixo
   - Arquivo afetado: qual .inc ou .md precisa ser alterado

2. Gere um plano de correção em Status/plano_correcao.xlsx com:
   - Aba 1: Tabela de feedbacks classificados com impacto e arquivo afetado
   - Aba 2: Ordem de execução das correções por prioridade
   - Cabeçalho azul escuro, cores por impacto

3. Execute as correções automaticamente:
   - Corrija os arquivos .inc afetados
   - Atualize o storytelling.md se necessário
   - Atualize a Biblioteca de Indicadores se regra de cálculo mudou
   - NUNCA sobrescrever arquivos .xlsx preenchidos pelo usuário
     exceto se o feedback indicar explicitamente

4. Após as correções, atualize:
   - Documentacao/relatorio_validacao.xlsx — registrar ajustes feitos
   - App/roteiro_validacao_usuario.md — marcar itens validados

5. Gere um resumo das correções feitas:
   - Quantos feedbacks foram processados
   - Quais arquivos foram alterados
   - O que ficou pendente e por quê

Antes de iniciar, instale as dependências:
pip install openpyxl python-docx -q --user