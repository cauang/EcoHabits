defmodule EcohabitsWeb.UserLive.Settings do
  use EcohabitsWeb, :live_view

  on_mount {EcohabitsWeb.UserAuth, :require_sudo_mode}

  alias Ecohabits.Accounts

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-xl mx-auto mt-8 bg-white p-8 rounded-2xl border border-gray-100 shadow-sm space-y-8">
      <div>
        <h1 class="text-2xl font-bold text-gray-900 tracking-tight">Configurações da Conta</h1>
        <p class="text-sm text-gray-500 mt-1">Gerencie seu endereço de e-mail e credenciais de acesso</p>
      </div>

      <.form for={@email_form} id="email_form" phx-submit="update_email" phx-change="validate_email" class="space-y-4">
        <.input
          field={@email_form[:email]}
          type="email"
          label="Alterar Endereço de E-mail"
          autocomplete="username"
          spellcheck="false"
          required
          class="w-full rounded-xl border border-gray-200 p-2.5"
        />
        <.button phx-disable-with="Alterando..." class="bg-emerald-600 hover:bg-emerald-700 text-white font-medium py-2 px-4 rounded-xl transition-colors text-sm shadow-sm">
          Atualizar E-mail
        </.button>
      </.form>

      <div class="border-t border-gray-100 my-6"></div>

      <.form
        for={@password_form}
        id="password_form"
        action={~p"/users/update-password"}
        method="post"
        phx-change="validate_password"
        phx-submit="update_password"
        phx-trigger-action={@trigger_submit}
        class="space-y-4"
      >
        <input
          name={@password_form[:email].name}
          type="hidden"
          id="hidden_user_email"
          value={@current_email}
        />

        <.input
          field={@password_form[:password]}
          type="password"
          label="Nova Senha"
          autocomplete="new-password"
          spellcheck="false"
          required
          class="w-full rounded-xl border border-gray-200 p-2.5"
        />

        <.input
          field={@password_form[:password_confirmation]}
          type="password"
          label="Confirmar Nova Senha"
          autocomplete="new-password"
          spellcheck="false"
          required
          class="w-full rounded-xl border border-gray-200 p-2.5"
        />

        <.button phx-disable-with="Salvando..." class="bg-emerald-600 hover:bg-emerald-700 text-white font-medium py-2 px-4 rounded-xl transition-colors text-sm shadow-sm">
          Salvar Nova Senha
        </.button>
      </.form>
    </div>
    """
  end

  @impl true
  def mount(%{"token" => token}, _session, socket) do
    socket =
      case Accounts.update_user_email(socket.assigns.current_user, token) do
        {:ok, _user} ->
          put_flash(socket, :info, "Endereço de e-mail alterado com sucesso!")

        {:error, _} ->
          put_flash(socket, :error, "O link de alteração de e-mail é inválido ou expirou.")
      end

    {:ok, push_navigate(socket, to: ~p"/users/settings")}
  end

  def mount(_params, _session, socket) do
    user = socket.assigns.current_user
    email_changeset = Accounts.change_user_email(user, %{}, validate_unique: false)
    password_changeset = Accounts.change_user_password(user, %{}, hash_password: false)

    socket =
      socket
      |> assign(:current_email, user.email)
      |> assign(:email_form, to_form(email_changeset))
      |> assign(:password_form, to_form(password_changeset))
      |> assign(:trigger_submit, false)

    {:ok, socket}
  end

  @impl true
  def handle_event("validate_email", %{"user" => user_params}, socket) do
    email_form =
      socket.assigns.current_user
      |> Accounts.change_user_email(user_params, validate_unique: false)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, email_form: email_form)}
  end

  def handle_event("update_email", %{"user" => user_params}, socket) do
    user = socket.assigns.current_user
    true = Accounts.sudo_mode?(user)

    case Accounts.change_user_email(user, user_params) do
      %{valid?: true} = changeset ->
        Accounts.deliver_user_update_email_instructions(
          Ecto.Changeset.apply_action!(changeset, :insert),
          user.email,
          &url(~p"/users/settings/confirm-email/#{&1}")
        )

        info = "Um link para confirmação foi enviado para o seu novo endereço de e-mail."
        {:noreply, socket |> put_flash(:info, info)}

      changeset ->
        {:noreply, assign(socket, :email_form, to_form(changeset, action: :insert))}
    end
  end

  def handle_event("validate_password", %{"user" => user_params}, socket) do
    password_form =
      socket.assigns.current_user
      |> Accounts.change_user_password(user_params, hash_password: false)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, password_form: password_form)}
  end

  def handle_event("update_password", %{"user" => user_params}, socket) do
    user = socket.assigns.current_user
    true = Accounts.sudo_mode?(user)

    case Accounts.change_user_password(user, user_params) do
      %{valid?: true} = changeset ->
        {:noreply, assign(socket, trigger_submit: true, password_form: to_form(changeset))}

      changeset ->
        {:noreply, assign(socket, password_form: to_form(changeset, action: :insert))}
    end
  end
end