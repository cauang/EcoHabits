defmodule EcohabitsWeb.HabitLive.Index do
  use EcohabitsWeb, :live_view

  alias Ecohabits.Habits
  alias Ecohabits.Habits.Habit

  def mount(_params, _session, socket) do
    habitos = Habits.list_habitos()
    changeset = Habits.change_habito(%Habit{})

    {:ok,
     socket
     |> assign(:habitos, habitos)
     |> assign(:form, to_form(changeset))}
  end

  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :new, _params) do
    assign(socket, :page_title, "Novo Hábito")
  end

  defp apply_action(socket, :index, _params) do
    assign(socket, :page_title, "Meus Hábitos")
  end

  def handle_event("save", %{"habit" => habit_params}, socket) do
    habit_params = Map.put(habit_params, "usuario_id", 1)

    case Habits.create_habito(habit_params) do
      {:ok, _habit} ->
        {:noreply,
         socket
         |> put_flash(:info, "Hábito criado com sucesso.")
         |> push_patch(to: ~p"/habitos")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  def render(assigns) do
    ~H"""
    <div class="max-w-6xl mx-auto p-6 bg-slate-50 min-h-screen">
      <div class="flex justify-between items-center mb-6">
        <div>
          <h1 class="text-3xl font-bold text-gray-900">Meus Hábitos</h1>
        </div>
        <.link patch={~p"/habitos/novo"} class="bg-teal-600 hover:bg-teal-700 text-white px-4 py-2 rounded-lg font-medium">
          Novo Hábito
        </.link>
      </div>

      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        <%= for habito <- @habitos do %>
          <div class="bg-white p-5 rounded-xl shadow-sm border border-gray-200">
            <h3 class="font-semibold text-gray-800"><%= habito.nome %></h3>
            <p class="text-gray-500 text-sm mt-2"><%= habito.descricao %></p>
            <div class="flex items-center gap-3 mt-4 text-xs">
              <span class="bg-gray-100 text-gray-600 px-2 py-1 rounded-md font-medium">Cat: <%= habito.categoria_id %></span>
              <span class="text-teal-600 font-semibold"><%= habito.pontuacao %> pts</span>
            </div>
          </div>
        <% end %>
      </div>

      <.modal :if={@live_action == :new} id="habit-modal" show on_cancel={JS.patch(~p"/habitos")}>
        <div class="p-4">
          <h2 class="text-2xl font-bold mb-4">Criar Novo Hábito</h2>
          <.form for={@form} phx-submit="save" class="flex flex-col gap-4">
            <.input field={@form[:nome]} type="text" label="Nome do Hábito" />
            <.input field={@form[:descricao]} type="textarea" label="Descrição" />
            <.input field={@form[:pontuacao]} type="number" label="Pontuação" />
            <.input field={@form[:categoria_id]} type="number" label="ID da Categoria (Ex: 1)" />

            <div class="flex justify-end mt-4">
              <.button type="submit" class="bg-teal-600 text-white">Salvar</.button>
            </div>
          </.form>
        </div>
      </.modal>
    </div>
    """
  end
end
