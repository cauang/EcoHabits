defmodule EcohabitsWeb.UserLive.Confirmation do
  use EcohabitsWeb, :live_view

  alias Ecohabits.Accounts

  @impl true
  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-sm mt-12 bg-white p-8 rounded-2xl border border-gray-100 shadow-sm">
      <div class="text-center mb-6">
        <h1 class="text-2xl font-bold text-gray-900 tracking-tight">Bem-vindo(a)!</h1>
        <p class="text-sm text-gray-500 mt-1">{@user.email}</p>
      </div>

      <.form
        :if={!@user.confirmed_at}
        for={@form}
        id="confirmation_form"
        phx-mounted={JS.focus_first()}
        phx-submit="submit"
        action={~p"/users/log-in?_action=confirmed"}
        phx-trigger-action={@trigger_submit}
        class="space-y-3"
      >
        <input type="hidden" name={@form[:token].name} value={@form[:token].value} />

        <.button
          name={@form[:remember_me].name}
          value="true"
          phx-disable-with="Confirmando..."
          class="w-full bg-emerald-600 hover:bg-emerald-700 text-white font-medium py-2.5 px-4 rounded-xl transition-colors shadow-sm"
        >
          Confirmar e manter conectado
        </.button>

        <.button phx-disable-with="Confirming..." class="w-full border border-gray-200 bg-white hover:bg-gray-50 text-gray-700 font-medium py-2.5 px-4 rounded-xl transition-colors shadow-sm text-sm">
          Confirmar apenas desta vez
        </.button>
      </.form>

      <.form
        :if={@user.confirmed_at}
        for={@form}
        id="login_form"
        phx-submit="submit"
        phx-mounted={JS.focus_first()}
        action={~p"/users/log-in"}
        phx-trigger-action={@trigger_submit}
        class="space-y-3"
      >
        <input type="hidden" name={@form[:token].name} value={@form[:token].value} />

        <.button
          name={@form[:remember_me].name}
          value="true"
          phx-disable-with="Acessando..."
          class="w-full bg-emerald-600 hover:bg-emerald-700 text-white font-medium py-2.5 px-4 rounded-xl transition-colors shadow-sm"
        >
          Manter conectado neste dispositivo
        </.button>

        <.button phx-disable-with="Acessando..." class="w-full border border-gray-200 bg-white hover:bg-gray-50 text-gray-700 font-medium py-2.5 px-4 rounded-xl transition-colors shadow-sm text-sm">
          Entrar apenas desta vez
        </.button>
      </.form>

      <p :if={!@user.confirmed_at} class="mt-6 text-xs text-center text-gray-500 bg-gray-50 p-3 rounded-xl border border-gray-100">
        Dica: Se preferir usar senhas tradicionais, você poderá habilitá-las na tela de configurações do seu perfil.
      </p>
    </div>
    """
  end

  @impl true
  def mount(%{"token" => token}, _session, socket) do
    if user = Accounts.get_user_by_magic_link_token(token) do
      form = to_form(%{"token" => token}, as: "user")

      {:ok, assign(socket, user: user, form: form, trigger_submit: false),
        temporary_assigns: [form: nil]}
    else
      {:ok,
        socket
        |> put_flash(:error, "O link mágico de acesso é inválido ou já expirou.")
        |> push_navigate(to: ~p"/users/log-in")}
    end
  end

  @impl true
  def handle_event("submit", %{"user" => params}, socket) do
    {:noreply, assign(socket, form: to_form(params, as: "user"), trigger_submit: true)}
  end
end