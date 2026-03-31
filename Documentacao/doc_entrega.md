# Documentação de Entrega — Performance Comercial

**Projeto:** Monitoramento de Performance Comercial
**Cliente:** Equipe Comercial (Diretores, Gerentes e Consultores de Vendas)
**Data de entrega:** 2026-03-31
**Versão:** 1.0
**Responsável técnico:** Analista de BI
**Validadores:** Gerente Comercial · Analista de BI

---

## 1. Resumo do Projeto

O projeto entrega um painel analítico em **Qlik Sense** para monitoramento da performance comercial da equipe de vendas. O objetivo é substituir o processo manual de consolidação em Excel (realizado semanalmente pelo analista) por um **dashboard atualizado diariamente às 6h**, com dados direto do ERP Protheus.

| Atributo | Detalhe |
|---|---|
| Ferramenta | Qlik Sense |
| Fonte principal | ERP Protheus (SQL Server) |
| Fonte secundária | Planilha de Metas (Excel — importada para `dbo.Metas`) |
| Histórico | 24 meses |
| Refresh | Diário às 06h (Qlik Cloud Reload Tasks) |
| Controle de acesso | Section Access por perfil (Consultor / Gerente / Diretor) |
| Indicadores entregues | 20 KPIs e métricas de análise |
| Sheets do app | 4 (Visão Executiva, Performance Comercial, Produtos, Financeiro) |

---

## 2. Fonte de Dados e Conexão

### 2.1 Conexão configurada

**Arquivo:** `Extracao/config/conexao.inc`

```qlik
LIB CONNECT TO 'Protheus_SQLServer';
```

A Data Connection `Protheus_SQLServer` deve ser criada no **Qlik Cloud Management Console** (ou Qlik Sense Desktop) apontando para o SQL Server do ERP Protheus, com as credenciais fornecidas pelo DBA responsável.

**Alternativa via string OLEDB (Qlik Sense Desktop):**
```
Provider=SQLOLEDB.1; Data Source=<SERVIDOR>; Initial Catalog=<BANCO>;
User ID=<USUARIO>; Password=<SENHA>;
```

### 2.2 Tabelas de origem

| Tabela de Origem | Tipo | Registros extraídos |
|---|---|---|
| `dbo.Pedidos` | Fato (vendas) | Filtrado por `DataEmissao` (24 meses) |
| `dbo.Financeiro` | Fato (financeiro) | Filtrado por `Data_Vencimento` (24 meses) |
| `dbo.Metas` | Fato (metas) | Todos os registros (planilha importada) |
| `dbo.Clientes` | Dimensão | Completo |
| `dbo.Consultores` | Dimensão | Completo |
| `dbo.Produtos` | Dimensão | Completo |

---

## 3. Modelo de Dados

### 3.1 Padrão: Star Schema (Modelo Estrela)

```
                    dim_tempo
                       │
          ┌────────────┼────────────┐
          │            │            │
      fato_vendas  fato_financeiro  fato_metas
          │                             │
    ┌─────┼─────┐                  dim_consultor
    │     │     │
dim_cliente dim_consultor dim_produto
```

### 3.2 Dimensões

| Tabela QVD | Granularidade | Chave PK | Fonte | Campos principais |
|---|---|---|---|---|
| `dim_tempo` | 1 linha por dia (calendário) | `ID_Data` (YYYYMMDD) | Gerada via script | Data, Dia, Mês, Trimestre, Semestre, Ano, Dia_Semana, Flag_Fim_Semana |
| `dim_cliente` | 1 linha por cliente | `ID_Cliente` | `dbo.Clientes` | Nome_Cliente, Data_Primeira_Compra |
| `dim_consultor` | 1 linha por consultor | `ID_Consultor` | `dbo.Consultores` | Nome_Consultor, Gerencia_Regional, Regiao, UF |
| `dim_produto` | 1 linha por produto | `ID_Produto` | `dbo.Produtos` | Nome_Produto, Linha_Produto |

### 3.3 Fatos

| Tabela QVD | Granularidade | FKs | Métricas principais |
|---|---|---|---|
| `fato_vendas` | 1 linha por pedido | ID_Data, ID_Cliente, ID_Consultor, ID_Produto | Valor_Venda, Valor_Bruto, Valor_Desconto, Custo_Produto, Status_Pedido, Canal_Venda |
| `fato_financeiro` | 1 linha por título/parcela | ID_Data_Vencimento, ID_Data_Pagamento, ID_Cliente | Valor_Total, Valor_Em_Atraso, Status_Financeiro |
| `fato_metas` | 1 linha por consultor/mês | ID_Consultor, ID_Data | Valor_Meta |

### 3.4 Hierarquia Comercial

```
Diretoria
└── Gerencia_Regional   (campo em dim_consultor)
    └── Nome_Consultor
        └── Regiao / UF
```

### 3.5 DDL completo

O DDL com todas as tabelas, constraints e índices de performance está em:
`Extracao/ddl_modelo_estrela.sql`

---

## 4. Scripts de Extração

### 4.1 Estrutura de arquivos

```
Extracao/
├── config/
│   ├── conexao.inc          ← String de conexão (SQL Server / ODBC)
│   └── variaveis.inc        ← vDataInicio, vDataFim, vRefresh, vPathQVD
├── 01_extract_dim_cliente.inc
├── 02_extract_dim_consultor.inc
├── 03_extract_dim_produto.inc
├── 04_extract_dim_tempo.inc  ← Calendário gerado via script (sem SQL)
├── 05_extract_fato_vendas.inc
├── 06_extract_fato_financeiro.inc
├── 07_extract_fato_metas.inc
├── main_load.inc             ← Orquestrador (chamar este no app)
└── QVDs/                    ← QVDs gerados pela extração
```

### 4.2 Variáveis globais (`variaveis.inc`)

| Variável | Valor | Descrição |
|---|---|---|
| `vDataFim` | `Today()` | Data final da janela de extração |
| `vDataInicio` | `AddMonths(Today(), -24)` | 24 meses de histórico |
| `vDataInicioSQL` | `Date(vDataInicio, 'YYYY-MM-DD')` | Formato para WHERE no SQL |
| `vDataFimSQL` | `Date(vDataFim, 'YYYY-MM-DD')` | Formato para WHERE no SQL |
| `vRefresh` | `'06:00'` | Horário do reload diário |
| `vPathQVD` | `'lib://DataFiles/QVDs/'` | Caminho dos QVDs no Qlik Cloud |
| `vNomeProjeto` | `'Performance Comercial'` | Metadado do projeto |

### 4.3 Padrão de cada script `.inc`

1. `$(Must_Include=...conexao.inc)` — conecta à fonte
2. `$(Must_Include=...variaveis.inc)` — carrega variáveis
3. `LOAD / SELECT` — extrai campos com aliases do DDL
4. `ISNULL()` — trata nulos (textos → `'NAO INFORMADO'`, números → `0`)
5. Filtro por `vDataInicioSQL` / `vDataFimSQL`
6. `STORE ... INTO [$(vPathQVD)tabela.qvd] (qvd)` — persiste QVD
7. `DROP TABLE` — libera memória

### 4.4 Como executar

No script principal do app Qlik Sense, adicionar:
```qlik
$(Must_Include=[lib://DataFiles/Extracao/main_load.inc]);
```

---

## 5. Scripts de Transformação

### 5.1 Estrutura de arquivos

```
Transformacao/
├── 01_transform_faturamento.inc   ← Indicadores 1,4,7–13,19,20
├── 02_transform_financeiro.inc    ← Indicadores 6,14–17
├── 03_transform_metas.inc         ← Indicadores 2,3,18
├── main_transform.inc             ← Orquestrador (chamar após extração)
└── QVDs/                          ← QVDs enriquecidos
    ├── fato_vendas_final.qvd
    ├── resumo_faturamento_mensal.qvd
    ├── fato_financeiro_enriched.qvd
    ├── resumo_inadimplencia.qvd
    ├── dim_cliente_enriched.qvd
    ├── fato_metas_enriched.qvd
    └── resumo_metas_gerencia.qvd
```

### 5.2 Regras de negócio por script

**`01_transform_faturamento.inc`**
- Calcula `Margem_Absoluta = Valor_Venda - Custo_Produto` por pedido
- Flag `Flag_Desconto_Alto` (desconto > 10%)
- Flag `Flag_Fechado` para Taxa de Conversão
- Enriquece `fato_vendas` com Regiao, UF, Gerencia_Regional e Linha_Produto via `ApplyMap`
- Gera `resumo_faturamento_mensal` agrupado por consultor/mês para suporte a MoM/YoY

**`02_transform_financeiro.inc`**
- Calcula `Dias_Atraso = Data_Pagamento - Data_Vencimento`
- Flag `Flag_Inadimplente` (status = 'Atrasado')
- Enriquece `dim_cliente` com segmento (Ativo / Novo / Inativo)
- Gera `resumo_inadimplencia` por cliente/mês

**`03_transform_metas.inc`**
- Junta metas com realizado (`resumo_faturamento_mensal`) via `ApplyMap`
- Calcula `Perc_Atingimento = Fat_Mensal / Valor_Meta`
- Gera `resumo_metas_gerencia` por gerência/mês

### 5.3 Padrão anti-chave-sintética

Todas as transformações usam `ApplyMap` / `MAPPING LOAD` em vez de `JOIN` para enriquecer as tabelas fato com atributos dimensionais, evitando loops e chaves sintéticas no modelo do Qlik.

### 5.4 Como executar

Após a extração, adicionar no script do app:
```qlik
$(Must_Include=[lib://DataFiles/Transformacao/main_transform.inc]);
```

---

## 6. Agendamento de Carga

### 6.1 Configuração no Qlik Cloud

| Parâmetro | Valor |
|---|---|
| Tipo | Reload Task |
| Frequência | Diária |
| Horário | 06:00 (fuso horário local) |
| App | Performance Comercial |
| Script | Executa `main_load.inc` → `main_transform.inc` |
| Notificação em falha | E-mail para o Analista de BI responsável |

### 6.2 Ordem de execução obrigatória

```
1. main_load.inc        ← Extração (SQL Server → QVDs brutos)
2. main_transform.inc   ← Transformação (QVDs brutos → QVDs enriquecidos)
```

---

## 7. Section Access (Controle de Acesso)

Conforme levantamento de requisitos: Consultor vê apenas os próprios dados, Gerente Regional vê sua gerência, Diretor vê tudo.

```qlik
Section Access;
LOAD * INLINE [
    ACCESS,  USERID,           OMIT
    ADMIN,   DIRETOR_001,
    USER,    GERENTE_SUL,      ID_Consultor
    USER,    CONSULTOR_001,    ID_Consultor; Gerencia_Regional; Regiao
];
Section Application;
```

**Passos para configurar no Qlik Cloud:**
1. Criar grupos: `DIRETORES`, `GERENTES_REGIONAIS`, `CONSULTORES`
2. Mapear e-mails corporativos nos grupos no Management Console
3. Substituir `USERID` pelos e-mails ou grupos reais
4. Testar com usuário de cada perfil antes do go-live
5. Documentar matriz de acesso em `Documentacao/matriz_acesso.md`

---

## 8. Indicadores Entregues

| # | Indicador | Regra de Cálculo | Script | Unidade | Meta |
|---|---|---|---|---|---|
| 1 | Faturamento Realizado | `SUM(Valor_Venda)` | transform_faturamento | R$ | Por consultor/mês |
| 2 | Meta de Faturamento | `SUM(Valor_Meta)` | transform_metas | R$ | Definida no início do mês |
| 3 | % Atingimento de Meta | `Faturamento / Meta` | transform_metas | % | 100% |
| 4 | Ticket Médio | `SUM(Valor_Venda) / COUNT(ID_Pedido)` | transform_faturamento | R$ | A definir |
| 5 | Taxa de Conversão | `COUNT(Fechados) / COUNT(Total)` | transform_faturamento | % | A definir |
| 6 | Inadimplência | `SUM(Valor_Em_Atraso) / SUM(Valor_Total)` | transform_financeiro | % | < 5% |
| 7 | Qtd de Pedidos | `COUNT(ID_Pedido)` | transform_faturamento | un | Por região |
| 8 | Faturamento por Região | `SUM(Valor_Venda) GROUP BY Regiao` | transform_faturamento | R$ | Por consultor |
| 9 | Faturamento por Consultor | `SUM(Valor_Venda) GROUP BY Consultor` | transform_faturamento | R$ | A definir |
| 10 | Faturamento por Produto | `SUM(Valor_Venda) GROUP BY Produto` | transform_faturamento | R$ | A definir |
| 11 | Faturamento por Canal | `SUM(Valor_Venda) GROUP BY Canal_Venda` | transform_faturamento | R$ | Positivo |
| 12 | Crescimento MoM | `(Mês Atual - Mês Ant.) / Mês Ant.` | transform_faturamento | % | Positivo |
| 13 | Crescimento YoY | `(Ano Atual - Ano Ant.) / Ano Ant.` | transform_faturamento | % | A definir |
| 14 | Qtd Clientes Ativos | `COUNT(DISTINCT ID_Cliente com venda > 0)` | transform_financeiro | un | A definir |
| 15 | Novos Clientes | `COUNT(1ª compra no mês atual)` | transform_financeiro | un | A definir |
| 16 | Clientes Inativos | `COUNT(última compra > 90 dias)` | transform_financeiro | un | 0 |
| 17 | Prazo Médio de Pagamento | `AVG(Data_Pagamento - Data_Vencimento)` | transform_financeiro | dias | < 30 dias |
| 18 | Valor Médio por Pedido | `SUM(Valor_Venda) / COUNT(ID_Pedido)` | transform_metas | R$ | A definir |
| 19 | % Desconto Médio | `SUM(Valor_Desconto) / SUM(Valor_Bruto)` | transform_faturamento | % | < 10% |
| 20 | Margem de Contribuição | `SUM(Valor_Venda - Custo) / SUM(Valor_Venda)` | transform_faturamento | % | > 30% |

---

## 9. Estrutura das Sheets do App

| Sheet | Objetivo | Público | Indicadores |
|---|---|---|---|
| 01 — Visão Executiva | Resultado geral do período | Diretor, Gerente | 1, 2, 3, 12, 13, 20 |
| 02 — Performance Comercial | Ranking por consultor e região | Gerente Comercial | 5, 8, 9, 3 por consultor |
| 03 — Análise de Produtos | Rentabilidade por produto e canal | Analista, Gerente | 10, 11, 19, 20, 18 |
| 04 — Financeiro | Saúde financeira e base de clientes | Financeiro, Diretor | 6, 14, 15, 16, 17 |

Especificação completa de cada objeto visual (tipo, dimensão, medida, Set Analysis) em:
`App/storytelling.md`

---

## 10. Pendências e Próximos Passos

| Prioridade | Ação | Responsável |
|---|---|---|
| 1 | Validar credenciais de conexão no SQL Server real | Analista de BI + DBA |
| 2 | Criar Data Connection `Protheus_SQLServer` no Qlik Cloud | Analista de BI |
| 3 | Executar reload completo com dados reais | Analista de BI |
| 4 | Construir as 4 sheets no Qlik Sense com base em `storytelling.md` | Analista de BI |
| 5 | Realizar sessão UAT com Gerente Comercial (usar `roteiro_validacao_usuario.md`) | Analista de BI |
| 6 | Corrigir indicadores com divergências encontradas no UAT | Analista de BI |
| 7 | Configurar Section Access com usuários reais | Analista de BI |
| 8 | Configurar Reload Task diária às 6h no Qlik Cloud | Analista de BI |
| 9 | Criar `Extracao/99_validacao_volume.inc` (reconciliação de registros) | Analista de BI |
| 10 | Documentar ata de validação e comunicar go-live | Gerente Comercial |

---

## 11. Estrutura de Arquivos Entregues

```
playbook_qlik/
├── Documentacao/
│   ├── 01_Levantamento_Requisitos.xlsx
│   ├── 02_Biblioteca_Indicadores.xlsx
│   ├── 03_Data_Request.xlsx
│   ├── 04_Checklist_Validacao.xlsx
│   ├── relatorio_validacao.md
│   ├── doc_entrega.md              ← este arquivo
│   ├── gameday.html
│   └── datahub.md
├── Extracao/
│   ├── config/
│   │   ├── conexao.inc
│   │   └── variaveis.inc
│   ├── 01_extract_dim_cliente.inc
│   ├── 02_extract_dim_consultor.inc
│   ├── 03_extract_dim_produto.inc
│   ├── 04_extract_dim_tempo.inc
│   ├── 05_extract_fato_vendas.inc
│   ├── 06_extract_fato_financeiro.inc
│   ├── 07_extract_fato_metas.inc
│   ├── ddl_modelo_estrela.sql
│   ├── modelo_dados.md
│   ├── main_load.inc
│   └── QVDs/
├── Transformacao/
│   ├── 01_transform_faturamento.inc
│   ├── 02_transform_financeiro.inc
│   ├── 03_transform_metas.inc
│   ├── main_transform.inc
│   └── QVDs/
└── App/
    ├── storytelling.md
    ├── roteiro_validacao_usuario.md
    └── wireframe_sheets.excalidraw
```
