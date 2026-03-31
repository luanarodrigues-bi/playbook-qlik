Leia os arquivos do projeto para entender a estrutura de dados:
- Documentacao/02_Biblioteca_Indicadores.xlsx
- Documentacao/03_Data_Request.xlsx
- Extracao/ddl_modelo_estrela.sql

Com base nesses arquivos, gere um script SQL completo para
popular o banco de dados local com dados fictícios realistas.

1. Criar banco de dados local
   - Verificar se o DDL já foi executado
   - Gerar script para criar o banco se não existir:
     CREATE DATABASE performance_comercial;
     USE performance_comercial;

2. Popular dimensões (executar nessa ordem):
   - dim_tempo — gerar calendário completo dos últimos 24 meses
   - dim_cliente — 50 clientes fictícios com nomes reais brasileiros
   - dim_consultor — 10 consultores com hierarquia
     (2 diretorias, 4 gerências, 10 consultores)
   - dim_produto — 20 produtos em 4 linhas de produto

3. Popular fatos (executar após dimensões):
   - fato_vendas — 5.000 pedidos distribuídos nos 24 meses
     * Valores entre R$ 1.000 e R$ 50.000
     * Mix de status: 70% Fechado, 20% Aberto, 10% Cancelado
     * Mix de canais: Direto, Distribuidor, E-commerce
     * Descontos entre 0% e 15%
   - fato_financeiro — títulos baseados nos pedidos fechados
     * 80% pagos no prazo
     * 15% pagos em atraso
     * 5% inadimplentes
   - fato_metas — metas mensais por consultor
     * Crescimento de 5% ao mês
     * Variação de ±10% entre consultores

4. Gerar KPIs esperados após carga
   Com base nos dados gerados, calcular e documentar:
   - Faturamento total esperado
   - Ticket médio esperado
   - Taxa de conversão esperada
   - Inadimplência esperada
   - % atingimento de meta esperado

   Salvar em Status/kpis_esperados.xlsx para validar
   contra os valores do Qlik após a carga

5. Salvar scripts em Extracao/sql_teste/:
   - 01_criar_banco.sql
   - 02_popular_dimensoes.sql
   - 03_popular_fatos.sql
   - 04_validar_volumes.sql — queries de COUNT por tabela

Antes de gerar, instale as dependências:
pip install openpyxl -q --user

Informe ao usuário:
- Scripts gerados e onde estão salvos
- Como executar no SSMS ou Azure Data Studio
- KPIs esperados após a carga
- Próximo passo: rodar main_load.inc no Qlik Desktop
```

Salva como `.claude/commands/preparar_sql_teste.md`. 

Agora temos todos os comandos! Resumo completo:
```
.claude/commands/
├── novo_projeto.md
├── iniciar_desev_qlik.md
├── Documentar_Desev._Qlik.md
├── avaliar_skill.md
├── status_projeto.md
├── corrigir_feedback.md
└── preparar_sql_teste.md