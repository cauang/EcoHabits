defmodule EcohabitsWeb.UserLive.Login do
  use EcohabitsWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <style>
      .forced-input-fix input {
        color: #111827 !important;
        background-color: #ffffff !important;
        border-color: #e5e7eb !important;
        border-radius: 0.75rem !important;
        padding: 0.75rem 1rem !important;
      }
      .forced-input-fix input::placeholder {
        color: #9ca3af !important;
        opacity: 1 !important;
      }
      .forced-input-fix label {
        color: #374151 !important;
        font-weight: 500 !important;
        margin-bottom: 0.25rem !important;
      }
    </style>

    <div class="min-h-screen w-full bg-gradient-to-br from-[#00b285] to-[#008060] flex flex-col items-center justify-center p-4 sm:p-6 lg:p-8">

      <div class="text-center mb-8 flex flex-col items-center">
        <div class="w-16 h-16 bg-white rounded-full flex items-center justify-center shadow-md mb-3">
          <img src={~p"/images/logo.svg"} alt="EcoHabits Logo" class="w-9 h-9 object-contain" />
        </div>
        <h1 class="text-4xl font-extrabold text-white tracking-tight">EcoHabits</h1>
        <p class="text-sm text-emerald-100 font-medium mt-1">Hábitos sustentáveis, impacto real</p>
      </div>

      <div class="w-full max-w-md bg-white p-8 sm:p-10 rounded-[2rem] shadow-xl forced-input-fix">
        <h2 class="text-2xl font-bold text-gray-900 mb-6">Entrar na sua conta</h2>

        <.form
          for={@form}
          id="login_form"
          action={~p"/users/log-in"}
          phx-change="validate"
          phx-submit="login"
          phx-trigger-action={@trigger_submit}
          class="space-y-5"
        >
          <.input
            field={@form[:email]}
            type="email"
            label="E-mail"
            placeholder="seu@email.com"
          />

          <.input
            field={@form[:password]}
            type="password"
            label="Senha"
            placeholder="••••••••"
          />

          <div class="flex items-center justify-between text-sm pt-1">
            <label class="flex items-center gap-2 text-gray-600 cursor-pointer">
              <input type="checkbox" name="user[remember_me]" class="rounded border-gray-300 text-[#009b74] focus:ring-[#009b74] size-4" />
              Lembrar-me
            </label>
            <a href="#" class="text-[#009b74] font-semibold hover:underline">Esqueceu a senha?</a>
          </div>

          <.button type="submit" phx-disable-with="Entrando..." class="w-full bg-[#009b74] hover:bg-[#008060] text-white font-bold py-3.5 rounded-xl transition-all shadow-md mt-6 text-center block text-base">
            Entrar
          </.button>

          <div class="text-center text-sm text-gray-600 pt-4 border-t border-gray-100 mt-6">
            Não tem uma conta?
            <.link navigate={~p"/users/register"} class="font-bold text-[#009b74] hover:underline">
              Cadastre-se
            </.link>
          </div>
        </.form>
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