defmodule EcohabitsWeb.UserLive.UserProfileLive do
  use EcohabitsWeb, :live_view
  alias Ecohabits.Accounts

  def mount(_params, _session, socket) do
    # Ajustado de current_user para ler o mapa de escopo correto do projeto
    user = socket.assigns.current_scope.user
    changeset = Accounts.change_user_profile(user)

    if socket.connected? do
      Phoenix.PubSub.subscribe(Ecohabits.PubSub, "user_profile:#{user.id}")
    end

    {:ok,
      socket
      |> assign(:page_title, "Meu Perfil")
      |> assign_form(changeset)}
  end

  def render(assigns) do
    ~H"""
    <div class="max-w-6xl mx-auto mt-8 px-4">
      <div class="mb-6">
        <h1 class="text-3xl font-bold text-gray-950">Meu Perfil</h1>
        <p class="text-gray-500 text-sm">Gerencie suas informações e acompanhe seu progresso</p>
      </div>

      <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
        <div class="md:col-span-2 bg-white rounded-2xl p-6 border border-gray-100 shadow-sm flex flex-col gap-6">
          <div class="flex items-center gap-4">
            <div class="w-20 h-20 bg-emerald-600 rounded-full flex items-center justify-center text-white text-2xl font-bold">
              {String.slice(@current_scope.user.name || "U", 0, 2) |> String.upcase()}
            </div>
            <div>
              <h2 class="text-2xl font-bold text-gray-900">{@current_scope.user.name || "Usuário"}</h2>
              <p class="text-gray-500 text-sm">{@current_scope.user.email}</p>
            </div>
          </div>

          <.form :let={f} for={@form} phx-submit="save" phx-change="validate" class="space-y-4 flex flex-col gap-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Nome Completo</label>
              <input
                type="text"
                name="user[name]"
                value={Phoenix.HTML.Form.input_value(f, :name)}
                class="w-full rounded-xl border border-gray-200 p-2.5 text-gray-900 focus:ring-2 focus:ring-emerald-500 focus:border-transparent focus:outline-none"
              />
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Bio (Status Sustentável)</label>
              <textarea
                name="user[bio]"
                rows={3}
                placeholder="Escreva um pouco sobre seus hábitos ecológicos..."
                class="w-full rounded-xl border border-gray-200 p-2.5 text-gray-900 focus:ring-2 focus:ring-emerald-500 focus:border-transparent focus:outline-none"
              ><%= Phoenix.HTML.Form.input_value(f, :bio) %></textarea>
            </div>

            <button
              type="submit"
              phx-disable-with="Salvando..."
              class="bg-emerald-600 hover:bg-emerald-700 text-white font-medium py-2.5 px-4 rounded-xl transition-colors w-full mt-2 shadow-sm"
            >
              Salvar Alterações
            </button>
          </.form>
        </div>

        <div class="bg-emerald-600 text-white rounded-2xl p-6 shadow-sm flex flex-col justify-between min-h-[250px]">
          <div>
            <div class="flex items-center gap-2 mb-2 opacity-90">
              <span class="text-sm font-medium uppercase tracking-wider">Pontuação Total</span>
            </div>
            <div class="text-5xl font-extrabold tracking-tight mb-4">
              {@current_scope.user.points || 0}
            </div>
          </div>

          <div class="border-t border-emerald-500/50 pt-4 mt-4">
            <div class="flex justify-between text-xs opacity-90 mb-1">
              <span>Nível Atual</span>
              <span class="font-bold">Eco Guardião</span>
            </div>
            <div class="w-full bg-emerald-700/50 h-2 rounded-full overflow-hidden">
              <div class="bg-white h-full w-[75%] rounded-full"></div>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset =
      socket.assigns.current_scope.user
      |> Accounts.change_user_profile(user_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"user" => user_params}, socket) do
    user = socket.assigns.current_scope.user

    case Accounts.update_user_profile(user, user_params) do
      {:ok, updated_user} ->
        {:noreply,
          socket
          |> put_flash(:info, "Perfil atualizado com sucesso!")
          |> assign_form(Accounts.change_user_profile(updated_user))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  def handle_info({:profile_updated, updated_user}, socket) do
    # Sincroniza dinamicamente o estado global do escopo
    new_scope = %{socket.assigns.current_scope | user: updated_user}
    {:noreply, assign(socket, :current_scope, new_scope)}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end
end