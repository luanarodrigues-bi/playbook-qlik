 Configuração do Figma MCP no Claude Code

## Pré-requisitos
- Claude Code instalado
- Conta no Figma

## Passo a Passo

### 1. Adicionar o servidor MCP do Figma
No terminal do Claude Code, rode:
claude mcp add --transport http figma-remote-mcp https://mcp.figma.com/mcp

### 2. Reiniciar o Claude Code
Feche e reabra o Claude Code na pasta do projeto:
exit
cd "C:\Users\SEU_USUARIO\SEU_PROJETO"
claude

### 3. Autenticar com o Figma
1. Digite /mcp no Claude Code
2. Selecione figma-remote-mcp
3. O browser abre automaticamente
4. Faça login no Figma e clique em Permitir acesso
5. Volte ao Claude Code e confirme com /mcp

### 4. Verificar conexão
Digite /mcp e verifique:
claude.ai Figma · ✔ connected
Status: connected
Tools: 15 tools

### 5. Testar
Cole no Claude Code:
Usando o MCP do Figma, crie um novo arquivo chamado Teste_Wireframe 
e adicione um frame simples com um retângulo azul.
Se abrir o arquivo no Figma com o retângulo azul — está funcionando!

## Observações
- Autenticação via OAuth — sem token manual
- Não expõe credenciais em nenhum arquivo
- 15 ferramentas disponíveis
- Configuração salva em C:\Users\SEU_USUARIO\.claude.json

## Solução de Problemas
- needs authentication - /mcp > selecione Figma - autentique novamente
- failed - /mcp - Clear authentication - reconecte
- Tools não aparecem -Reinicia o Claude Code completamente