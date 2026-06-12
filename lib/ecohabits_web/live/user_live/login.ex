defmodule EcohabitsWeb.UserLive.Login do
  use EcohabitsWeb, :live_view

  alias Ecohabits.Accounts

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
          <p class="text-emerald-100">Hábitos sustentáveis, impacto real</p>
        </div>

        <%!-- Login Card --%>
        <div class="bg-white rounded-2xl shadow-2xl p-8">
          <h2 class="text-2xl text-gray-800 mb-6">Entrar na sua conta</h2>

          <.form
            :let={f}
            for={@form}
            id="login_form_password"
            action={~p"/users/log-in"}
            phx-change="validate"
            phx-submit="submit_password"
            phx-trigger-action={@trigger_submit}
            class="space-y-5"
          >
            <%!-- Email --%>
            <div>
              <label class="block text-sm text-gray-700 mb-2">E-mail</label>
              <div class="relative">
                <.icon name="hero-envelope-solid" class="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400" />
                <input
                  type="email"
                  name={f[:email].name}
                  value={f[:email].value}
                  placeholder="seu@email.com"
                  class="w-full pl-11 pr-4 py-3 border border-gray-300 rounded-lg text-gray-900 focus:outline-none focus:ring-2 focus:ring-emerald-500 focus:border-transparent"
                  required
                />
              </div>
            </div>

            <%!-- Password --%>
            <div>
              <label class="block text-sm text-gray-700 mb-2">Senha</label>
              <div class="relative">
                <.icon name="hero-lock-closed-solid" class="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400" />
                <input
                  type="password"
                  name={f[:password].name}
                  value={f[:password].value}
                  placeholder="••••••••"
                  class="w-full pl-11 pr-4 py-3 border border-gray-300 rounded-lg text-gray-900 focus:outline-none focus:ring-2 focus:ring-emerald-500 focus:border-transparent"
                  required
                />
              </div>
            </div>


            <%!-- Login Button --%>
            <button
              class="block w-full bg-gradient-to-r from-emerald-500 to-teal-600 text-white py-3 rounded-lg hover:from-emerald-600 hover:to-teal-700 transition-all shadow-md hover:shadow-lg text-center"
            >
              Entrar
            </button>
          </.form>

          <%!-- Signup Link --%>
          <div class="mt-6 text-center">
            <p class="text-gray-600">
              Não tem uma conta?
              <.link navigate={~p"/users/register"} class="text-emerald-600 hover:text-emerald-700">
                Cadastre-se
              </.link>
            </p>
          </div>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    email =
      Phoenix.Flash.get(socket.assigns.flash, :email) ||
        get_in(socket.assigns, [:current_scope, Access.key(:user), Access.key(:email)])

    form = to_form(%{"email" => email}, as: "user")

    {:ok, assign(socket, form: form, trigger_submit: false)}
  end

  @impl true
  def handle_event("submit_password", _params, socket) do
    {:noreply, assign(socket, :trigger_submit, true)}
  end

  def handle_event("submit_magic", %{"user" => %{"email" => email}}, socket) do
    if user = Accounts.get_user_by_email(email) do
      Accounts.deliver_login_instructions(
        user,
        &url(~p"/users/log-in/#{&1}")
      )
    end

    info =
      "If your email is in our system, you will receive instructions for logging in shortly."

    {:noreply,
     socket
     |> put_flash(:info, info)
     |> push_navigate(to: ~p"/users/log-in")}
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    {:noreply, assign(socket, form: to_form(user_params, as: "user"))}
  end
end
