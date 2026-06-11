defmodule EcohabitsWeb.UserLive.Login do
  use EcohabitsWeb, :live_view

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

        <div class="bg-white rounded-2xl shadow-2xl p-8">
          <h2 class="text-2xl text-gray-800 mb-6">Entrar na sua conta</h2>

          <.form
            for={@form}
            id="login_form"
            action={~p"/users/log-in"}
            phx-change="validate"
            phx-submit="login"
            phx-trigger-action={@trigger_submit}
            class="space-y-5"
          >
            <div>
              <p class="block text-sm text-gray-700 mb-2">E-mail</p>
              <div class="relative">
                <.icon name="hero-envelope-solid" class="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400" />
                <.input
                  field={@form[:email]}
                  type="email"
                  label={nil}
                  placeholder="seu@email.com"
                  class="w-full rounded-lg border border-gray-300 pl-11 pr-4 py-3 text-gray-900 focus:outline-none focus:ring-2 focus:ring-emerald-500 focus:border-transparent"
                />
              </div>
            </div>

            <div>
              <p class="block text-sm text-gray-700 mb-2">Senha</p>
              <div class="relative">
                <.icon name="hero-lock-closed-solid" class="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400" />
                <.input
                  field={@form[:password]}
                  type="password"
                  label={nil}
                  placeholder="••••••••"
                  class="w-full rounded-lg border border-gray-300 pl-11 pr-4 py-3 text-gray-900 focus:outline-none focus:ring-2 focus:ring-emerald-500 focus:border-transparent"
                />
              </div>
            </div>

            <div class="flex items-center justify-between">
              <label class="flex items-center gap-2 text-gray-600 cursor-pointer">
                <input
                  type="checkbox"
                  name="user[remember_me]"
                  class="w-4 h-4 text-emerald-600 rounded border-gray-300 focus:ring-emerald-500"
                />
                Lembrar-me
              </label>
              <.link href="#" class="text-sm text-emerald-600 hover:text-emerald-700">
                Esqueceu a senha?
              </.link>
            </div>

            <.button
              type="submit"
              phx-disable-with="Entrando..."
              class="block w-full bg-gradient-to-r from-emerald-500 to-teal-600 text-white py-3 rounded-lg hover:from-emerald-600 hover:to-teal-700 transition-all shadow-md hover:shadow-lg text-center"
            >
              Entrar
            </.button>
          </.form>

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
    current_scope = socket.assigns[:current_scope] || nil

    attempted_email = Phoenix.Flash.get(socket.assigns.flash, :attempted_email) || ""

    form =
      if attempted_email != "" do
        to_form(%{"email" => attempted_email, "password" => ""}, as: "user", action: "validate")
      else
        to_form(%{"email" => attempted_email, "password" => ""}, as: "user")
      end

    {:ok, assign(socket, form: form, current_scope: current_scope, trigger_submit: false), temporary_assigns: [form: nil]}
  end

  @impl true
  def handle_event("validate", %{"user" => user_params}, socket) do
    form = to_form(user_params, as: "user", action: "validate")
    {:noreply, assign(socket, form: form)}
  end

  @impl true
  def handle_event("login", %{"user" => user_params}, socket) do
    email = user_params["email"] || ""
    password = user_params["password"] || ""

    if String.trim(email) == "" or String.trim(password) == "" do
      errors = []
      errors = if String.trim(email) == "", do: [{"email", {"não pode ficar em branco", []}} | errors], else: errors
      errors = if String.trim(password) == "", do: [{"password", {"não pode ficar em branco", []}} | errors], else: errors

      form = to_form(user_params, as: "user", action: "validate", errors: errors)
      {:noreply, socket |> assign(form: form, trigger_submit: false) |> put_flash(:error, "Por favor, preencha todos os campos.")}
    else
      form = to_form(user_params, as: "user")
      {:noreply, assign(socket, form: form, trigger_submit: true)}
    end
  end
end
