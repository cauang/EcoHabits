defmodule EcohabitsWeb.UserSessionController do
  use EcohabitsWeb, :controller

  alias Ecohabits.Accounts
  alias EcohabitsWeb.UserAuth

  # 1. Renderiza a tela de login (PÚBLICA)
  def new(conn, _params) do
    render(conn, :new)
  end

  # 2. Captura o POST caso venha com ação de confirmação (PÚBLICA)
  def create(conn, %{"_action" => "confirmed"} = params) do
    create(conn, params, "User confirmed successfully.")
  end

  # 3. Captura o POST padrão do formulário de login (PÚBLICA)
  # Esta função resolve o ActionClauseError recebendo a requisição do roteador
  def create(conn, %{"user" => user_params}) do
    create(conn, user_params, "Welcome back!")
  end

  # 4. Pipeline Único de Autenticação (PRIVADA)
  # Centraliza a validação do e-mail e senha recebendo os parâmetros já desembrulhados
  defp create(conn, %{"email" => email, "password" => password}, info) do
    if user = Accounts.get_user_by_email_and_password(email, password) do
      conn
      |> put_flash(:info, info)
      |> UserAuth.log_in_user(user, %{"email" => email})
    else
      conn
      |> put_flash(:error, "E-mail ou senha inválidos.")
      |> put_flash(:attempted_email, String.slice(email, 0, 160))
      |> redirect(to: ~p"/users/log-in")
    end
  end

  # 5. Atualização de senha (PÚBLICA)
  def update_password(conn, %{"user" => user_params} = params) do
    user = conn.assigns.current_scope.user
    true = Accounts.sudo_mode?(user)
    {:ok, {_user, expired_tokens}} = Accounts.update_user_password(user, user_params)

    UserAuth.disconnect_sessions(expired_tokens)

    conn
    |> put_session(:user_return_to, ~p"/users/settings")
    |> create(params, "Password updated successfully!")
  end

  # 6. Logout (PÚBLICA)
  def delete(conn, _params) do
    conn
    |> put_flash(:info, "Logged out successfully.")
    |> UserAuth.log_out_user()
  end
end