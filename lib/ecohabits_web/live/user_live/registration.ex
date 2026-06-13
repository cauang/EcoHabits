defmodule EcohabitsWeb.UserLive.Registration do
  use EcohabitsWeb, :live_view

  alias Ecohabits.Accounts
  alias Ecohabits.Accounts.User

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gradient-to-br from-emerald-500 via-teal-600 to-cyan-700 flex items-center justify-center p-4">
      <div class="w-full max-w-md">

        <div class="text-center mb-8">
          <div class="inline-flex items-center justify-center w-20 h-20 bg-white rounded-full mb-4 shadow-lg p-2">
            <img src={~p"/images/logo.svg"} alt="EcoHabits Logo" class="w-full h-full object-contain" />
          </div>
          <h1 class="text-4xl text-white mb-2">EcoHabits</h1>
          <p class="text-emerald-100">Comece sua jornada sustentável</p>
        </div>


        <div class="bg-white rounded-2xl shadow-2xl p-8">
          <h2 class="text-2xl text-gray-800 mb-6">Criar conta</h2>

          <.form for={@form} id="registration_form" phx-submit="save" phx-change="validate" class="space-y-5">

            <div>
              <label class="block text-sm text-gray-700 mb-2">Nome completo</label>
              <div class="relative">
                <.icon name="hero-user-solid" class="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400" />
                <input
                  type="text"
                  name={@form[:name].name}
                  value={@form[:name].value}
                  placeholder="Seu nome"
                  class="w-full pl-11 pr-4 py-3 border border-gray-300 rounded-lg text-gray-900 focus:outline-none focus:ring-2 focus:ring-emerald-500 focus:border-transparent"
                  required
                />
              </div>
              <p :for={err <- @form[:name].errors} class="mt-2 text-sm text-red-600 flex items-center gap-1">
                <.icon name="hero-exclamation-circle-mini" class="w-4 h-4" />
                {translate_error(err)}
              </p>
            </div>


            <div>
              <label class="block text-sm text-gray-700 mb-2">E-mail</label>
              <div class="relative">
                <.icon name="hero-envelope-solid" class="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400" />
                <input
                  type="email"
                  name={@form[:email].name}
                  value={@form[:email].value}
                  placeholder="seu@email.com"
                  class="w-full pl-11 pr-4 py-3 border border-gray-300 rounded-lg text-gray-900 focus:outline-none focus:ring-2 focus:ring-emerald-500 focus:border-transparent"
                  required
                  phx-debounce="blur"
                />
              </div>
              <p :for={err <- @form[:email].errors} class="mt-2 text-sm text-red-600 flex items-center gap-1">
                <.icon name="hero-exclamation-circle-mini" class="w-4 h-4" />
                {translate_error(err)}
              </p>
            </div>


            <div>
              <label class="block text-sm text-gray-700 mb-2">Senha</label>
              <div class="relative">
                <.icon name="hero-lock-closed-solid" class="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400" />
                <input
                  type="password"
                  name={@form[:password].name}
                  value={@form[:password].value}
                  placeholder="Mínimo 12 caracteres"
                  class="w-full pl-11 pr-4 py-3 border border-gray-300 rounded-lg text-gray-900 focus:outline-none focus:ring-2 focus:ring-emerald-500 focus:border-transparent"
                  required
                  phx-debounce="blur"
                />
              </div>
              <p :for={err <- @form[:password].errors} class="mt-2 text-sm text-red-600 flex items-center gap-1">
                <.icon name="hero-exclamation-circle-mini" class="w-4 h-4" />
                {translate_error(err)}
              </p>
            </div>


            <div>
              <label class="block text-sm text-gray-700 mb-2">Confirmar senha</label>
              <div class="relative">
                <.icon name="hero-lock-closed-solid" class="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400" />
                <input
                  type="password"
                  name={@form[:password_confirmation].name}
                  value={@form[:password_confirmation].value}
                  placeholder="Digite a senha novamente"
                  class="w-full pl-11 pr-4 py-3 border border-gray-300 rounded-lg text-gray-900 focus:outline-none focus:ring-2 focus:ring-emerald-500 focus:border-transparent"
                  required
                  phx-debounce="blur"
                />
              </div>
              <p :for={err <- @form[:password_confirmation].errors} class="mt-2 text-sm text-red-600 flex items-center gap-1">
                <.icon name="hero-exclamation-circle-mini" class="w-4 h-4" />
                {translate_error(err)}
              </p>
            </div>


            <button
              class="block w-full bg-gradient-to-r from-emerald-500 to-teal-600 text-white py-3 rounded-lg hover:from-emerald-600 hover:to-teal-700 transition-all shadow-md hover:shadow-lg text-center"
              phx-disable-with="Criando conta..."
            >
              Criar conta
            </button>
          </.form>


          <div class="mt-6 text-center">
            <p class="text-gray-600">
              Já tem uma conta?{" "}
              <.link navigate={~p"/users/log-in"} class="text-emerald-600 hover:text-emerald-700">
                Entrar
              </.link>
            </p>
          </div>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, %{assigns: %{current_scope: %{user: user}}} = socket)
      when not is_nil(user) do
    {:ok, redirect(socket, to: EcohabitsWeb.UserAuth.signed_in_path(socket))}
  end

  def mount(_params, _session, socket) do
    changeset = Accounts.change_user_registration(%User{}, %{}, validate_unique: false)

    {:ok, assign_form(socket, changeset), temporary_assigns: [form: nil]}
  end

  @impl true
  def handle_event("save", %{"user" => user_params}, socket) do
    case Accounts.register_user(user_params) do
      {:ok, user} ->
        {:ok, _} =
          Accounts.deliver_login_instructions(
            user,
            &url(~p"/users/log-in/#{&1}")
          )

        {:noreply,
         socket
         |> put_flash(:info, "Conta criada com sucesso!")
         |> push_navigate(to: ~p"/users/log-in")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset = Accounts.change_user_registration(%User{}, user_params, validate_unique: false)
    {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset, as: "user")
    assign(socket, form: form)
  end
end
