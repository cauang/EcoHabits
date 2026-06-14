# Ecohabits

Projeto web desenvolvido com o framework Elixir Phoenix.

## Como executar o projeto localmente

Siga estes passos simples para rodar a aplicação na sua máquina:

1. **Instale as dependências e configure o banco de dados:**
   ```bash
   mix setup
   ```

2. **Inicie o servidor web:**
   ```bash
   mix phx.server
   ```
   *(Dica: Se quiser iniciar com o console interativo do Elixir, rode `iex -S mix phx.server`)*

3. **Acesse a aplicação:**
   Abra o seu navegador e acesse [`http://localhost:4000`](http://localhost:4000)

## Outros comandos úteis

* Para testar a conexão com o banco de dados isoladamente:
  ```bash
  mix run --no-start tmp_connection_test.exs
  ```