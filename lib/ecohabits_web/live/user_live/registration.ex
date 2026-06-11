defmodule EcohabitsWeb.UserLive.Registration do
  use EcohabitsWeb, :live_view

  alias Ecohabits.Accounts
  alias Ecohabits.Accounts.User

  @impl true
  def render(assigns) do
    ~H"""
    <style>
      .forced-input-fix input {
        color: #111827 !important;
        background-color: #ffffff !important;
        border-color: #e5e7eb !important;
      }
      .forced-input-fix input::placeholder {
        color: #9ca3af !important;
        opacity: 1 !important;
      }
      .forced-input-fix label {
        color: #111827 !important;
        font-weight: 500 !important;
      }
    </style>

    <div class="mx-auto max-w-md mt-12 bg-white p-8 rounded-3xl border border-gray-100 shadow-md forced-input-fix">
      <div class="text-center mb-6">
        <h1 class="text-3xl font-bold text-gray-900 tracking-tight">Criar conta</h1>
        <p class="text-sm text-gray-500 mt-2">Comece sua jornada sustentável</p>
      </div>

      <.form
        for={@form}
        id="registration_form"
        phx-submit="save"
        phx-change="validate"
        action={~p"/users/log-in?_action=registered"}
        method="post"
        phx-trigger-action={@trigger_submit}
        class="space-y-4 text-left"
      >
        <.input
          field={@form[:name]}
          type="text"
          label="Nome completo"
          placeholder="Seu nome"
          required
        />

        <.input
          field={@form[:email]}
          type="email"
          label="E-mail"
          placeholder="seu@email.com"
          autocomplete="username"
          required
        />

        <.input
          field={@form[:password]}
          type="password"
          label="Senha"
          placeholder="Mínimo 8 caracteres"
          required
        />

        <.input
          field={@form[:password_confirmation]}
          type="password"
          label="Confirmar senha"
          placeholder="Digite a senha novamente"
          required
        />

        <.button phx-disable-with="Criando conta..." class="w-full bg-emerald-600 hover:bg-emerald-700 text-white font-medium py-3 rounded-xl transition-colors shadow-sm mt-6 text-center block">
          Criar conta
        </.button>

        <p class="text-center text-sm text-gray-600 mt-4">
          Já tem uma conta?
          <.link navigate={~p"/users/log-in"} class="font-semibold text-emerald-600 hover:underline">
            Entrar
          </.link>
        </p>
      </.form>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    current_scope = socket.assigns[:current_scope] || nil
    user = get_in(socket.assigns, [:current_scope, Access.key(:user)])

    if user do
      {:ok, redirect(socket, to: EcohabitsWeb.UserAuth.signed_in_path(socket))}
    else
      # Alterado para usar o changeset de registro sem aplicar hash na senha ainda (hash_password: false)
      changeset = User.registration_changeset(%User{}, %{}, hash_password: false, validate_unique: false)
      {:ok,
        socket
        |> assign(current_scope: current_scope, trigger_submit: false)
        |> assign_form(changeset), temporary_assigns: [form: nil]}
    end
  end

  @impl true
  def handle_event("validate", %{"user" => user_params}, socket) do
    # Força a validação em tempo real de todos os campos baseados na regra de 8 caracteres
    changeset = User.registration_changeset(%User{}, user_params, hash_password: false, validate_unique: false)
    {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  end

  @impl true
  def handle_event("save", %{"user" => user_params}, socket) do
    case Accounts.register_user(user_params) do
      {:ok, _user} ->
        {:noreply, assign(socket, trigger_submit: true)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset, as: "user")
    assign(socket, form: form)
  end
end