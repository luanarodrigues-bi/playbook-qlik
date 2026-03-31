Você é um avaliador especialista em qualidade de skills para Claude Code.

Leia o arquivo do skill informado em .claude/skills/[nome_skill]/SKILL.md

Execute o comando correspondente em um projeto de teste temporário
em /tmp/teste_skill/

Avalie o output gerado nos seguintes critérios:

1. Aderencia ao Padrao BIX
   - Arquivos gerados no formato correto (.inc, .xlsx, .docx, .pptx)?
   - Estrutura de pastas seguindo o padrão BIX?
   - Nomenclatura correta dos arquivos?
   - Dependências instaladas antes de gerar arquivos?

2. Qualidade Tecnica Qlik
   - Scripts .inc usando Must_Include corretamente?
   - ApplyMap em vez de JOIN?
   - Tratamento de nulos aplicado?
   - dim_tempo gerada via AUTOGENERATE?
   - STORE → QVD e DROP TABLE em todos os scripts?

3. Inteligencia Adaptativa
   - Claude leu os templates antes de gerar?
   - Detectou mudanças nos templates corretamente?
   - Não sobrescreveu arquivos existentes?
   - Não recriou o que não mudou?

4. Completude
   - Todos os arquivos esperados foram gerados?
   - Output esperado no SKILL.md foi atingido?
   - Próximos passos foram informados?

5. Erros Comuns
   - Algum erro listado no SKILL.md ocorreu?
   - Ocorreu algum erro não listado?

Para cada critério:
- Pontue de 0 a 10
- Justifique a pontuação
- Liste o que está bom
- Liste o que precisa melhorar

Gere um relatório em .claude/skills/[nome_skill]/avaliacao.md contendo:
- Tabela de pontuação por critério
- Nota final (média dos critérios)
- Lista de melhorias sugeridas para o SKILL.md
- SKILL.md reescrito com as melhorias aplicadas

Salve o SKILL.md melhorado em:
.claude/skills/[nome_skill]/SKILL_melhorado.md

Informe ao usuário:
- Nota antes da melhoria
- Nota estimada após melhoria
- Top 3 melhorias aplicadas
```

Salva como `.claude/commands/avaliar_skill.md` e usa assim:
```
/avaliar_skill novo_projeto
/avaliar_skill iniciar_desev_qlik
/avaliar_skill documentar_desev_qlik
