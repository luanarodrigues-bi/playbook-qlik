# Data Hub — Performance Comercial

> Registro de caso de uso para portfólio e base de conhecimento interno.

---

## Informações Gerais

| Atributo | Detalhe |
|---|---|
| **Nome do projeto** | Monitoramento de Performance Comercial |
| **Tecnologia utilizada** | Qlik Sense (Qlik Cloud) · SQL Server (T-SQL) · ERP Protheus · QVD Layer |
| **Data da entrega** | 31 de março de 2026 |
| **Idealizador(es)** | Analista de BI · Gerente Comercial |
| **Tipo de segmento** | Comercial / Vendas |
| **Área(s) impactada(s)** | Comercial · Financeiro · Diretoria |
| **Duração do projeto** | 3 semanas |

---

## Contexto e Problema

A equipe de vendas consolidava a performance comercial **manualmente em Excel toda segunda-feira**. O processo era sujeito a erro humano, produzia dados desatualizados e não permitia visão individualizada por consultor, gerência regional ou produto.

Sem acesso a dados em tempo real:
- Gestores tomavam decisões com 5–7 dias de atraso
- Não havia visibilidade da inadimplência por consultor
- A comparação de meta vs. realizado era feita pontualmente, sem histórico
- Consultores não tinham acesso fácil ao próprio desempenho

---

## Solução Entregue

Painel analítico em **Qlik Sense Cloud** conectado diretamente ao ERP Protheus (SQL Server), atualizado automaticamente todo dia às 6h, com controle de acesso por perfil.

### Principais componentes

| Componente | Descrição |
|---|---|
| Extração | 7 scripts `.inc` (4 dimensões + 3 fatos) extraindo do SQL Server para QVD |
| Transformação | 3 scripts `.inc` aplicando regras de negócio e enriquecimento |
| Modelo de dados | Star Schema: 4 dimensões × 3 fatos, sem chaves sintéticas |
| App | 4 sheets, 20 indicadores, filtros globais por Período/Região/UF/Consultor |
| Acesso | Section Access: Consultor (próprios dados) · Gerente (região) · Diretor (total) |

---

## Principais Resultados

| Indicador | Antes | Depois |
|---|---|---|
| Frequência de atualização | Semanal (manual, segunda-feira) | Diária às 6h (automático) |
| Indicadores monitorados | ~5 (Excel manual) | 20 (dashboard) |
| Tempo para obter dados | ~30 min de consolidação | Instantâneo (browser) |
| Controle de acesso | Nenhum (planilha compartilhada) | Section Access por perfil |
| Histórico disponível | Depende do analista | 24 meses navegáveis |
| Visão por consultor | Não | Sim (cada consultor vê apenas os próprios dados) |

---

## Mídia — Painéis e Fluxos

### Fluxo de dados

```
ERP Protheus (SQL Server)
        │
        ▼
Extração (main_load.inc)
7 scripts → QVDs brutos
        │
        ▼
Transformação (main_transform.inc)
3 scripts → QVDs enriquecidos
        │
        ▼
App Qlik Sense (4 sheets)
        │
        ▼
Usuário (Consultor / Gerente / Diretor)
```

### Screenshots do painel

**Sheet 01 — Visão Executiva**

> *[ Inserir screenshot da Sheet 01 — Faturamento, Meta, % Atingimento, MoM, YoY ]*

---

**Sheet 02 — Performance Comercial**

> *[ Inserir screenshot da Sheet 02 — Ranking de Consultores, Faturamento por Região, % Atingimento ]*

---

**Sheet 03 — Análise de Produtos**

> *[ Inserir screenshot da Sheet 03 — Faturamento por Produto/Canal, % Desconto, Margem ]*

---

**Sheet 04 — Financeiro**

> *[ Inserir screenshot da Sheet 04 — Inadimplência, Prazo Médio, Clientes Ativos/Novos/Inativos ]*

---

**Diagrama do modelo de dados (Star Schema)**

> *[ Inserir print do diagrama Mermaid gerado em Extracao/modelo_dados.md ]*

---

## Principais Desafios

| # | Desafio | Como foi resolvido |
|---|---|---|
| 1 | **Estrutura de tabelas do ERP Protheus** | Mapeamento dos campos via Data Request colaborativo com o analista de negócio; aliases no SELECT alinhados ao DDL do modelo estrela |
| 2 | **Evitar chaves sintéticas no Qlik** | Uso de `ApplyMap` / `MAPPING LOAD` em vez de `JOIN` em todas as transformações — modelo estrela limpo sem loops |
| 3 | **Controle de acesso granular** | Section Access com três perfis (Consultor, Gerente, Diretor) — cada nível com visibilidade restrita por `OMIT` nos campos de hierarquia |
| 4 | **Crescimento MoM e YoY em Set Analysis** | Tabela de resumo mensal pré-agregada (`resumo_faturamento_mensal`) para suportar comparações de período sem sobrecarregar o motor do Qlik |
| 5 | **Definição de "cliente inativo"** | Alinhamento com o negócio: inativo = sem compra nos últimos 90 dias corridos — regra implementada na camada de transformação e documentada no Data Request |
| 6 | **Fonte de metas em Excel** | Planilha de metas importada mensalmente para `dbo.Metas` no SQL Server — padronização do processo de entrada de dados com o Gerente Comercial |

---

## Insights Relevantes

1. **O indicador mais crítico para o negócio é o % Atingimento de Meta por consultor** — é o único que permite acionar individualmente consultores fora da trajetória antes do fechamento do mês.

2. **A camada de QVD em duas fases (extração + transformação) reduziu o script do app Qlik a praticamente zero** — todo o processamento acontece nos `.inc`, tornando o app fácil de manter e reutilizar.

3. **A hierarquia Diretoria > Gerência Regional > Consultor** já estava no ERP Protheus mas nunca havia sido explorada analiticamente — o painel expõe esse dado e permite drill-down natural no Qlik.

4. **A inadimplência era monitorada apenas pelo financeiro** — com o painel, o gerente comercial passou a ter visibilidade direta dos clientes em atraso vinculados à sua carteira de consultores.

5. **Section Access como diferencial de adoção** — consultores só veem os próprios dados, o que reduziu a resistência inicial ("não quero que o colega veja meus números") e aumentou a confiança na ferramenta.

---

## Lições Aprendidas

- **Iniciar pelo Data Request antes de qualquer código**: mapear os campos e regras com o analista de negócio antes de escrever uma linha de SQL economizou retrabalho.
- **ApplyMap sempre que possível**: qualquer `JOIN` em script Qlik é um risco de chave sintética — `ApplyMap` deve ser a primeira opção.
- **Documentar o Set Analysis no storytelling**: ter a fórmula Qlik documentada junto ao indicador facilita muito a validação com o usuário.
- **Metas em planilha são um ponto de atenção operacional**: o processo de importação mensal precisa de responsável definido e checklist de validação antes do reload.

---

## Referências e Artefatos

| Artefato | Caminho |
|---|---|
| Levantamento de Requisitos | `Documentacao/01_Levantamento_Requisitos.xlsx` |
| Biblioteca de Indicadores | `Documentacao/02_Biblioteca_Indicadores.xlsx` |
| Data Request | `Documentacao/03_Data_Request.xlsx` |
| Checklist de Validação | `Documentacao/04_Checklist_Validacao.xlsx` |
| Relatório de Validação Técnica | `Documentacao/relatorio_validacao.md` |
| Documentação de Entrega | `Documentacao/doc_entrega.md` |
| Game Day (apresentação) | `Documentacao/gameday.html` |
| Modelo de Dados (Mermaid) | `Extracao/modelo_dados.md` |
| DDL SQL Server | `Extracao/ddl_modelo_estrela.sql` |
| Storytelling do App | `App/storytelling.md` |
| Roteiro de Validação com Usuário | `App/roteiro_validacao_usuario.md` |
