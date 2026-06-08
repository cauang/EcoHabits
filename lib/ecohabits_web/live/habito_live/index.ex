defmodule EcohabitsWeb.HabitoLive.Index do
  use EcohabitsWeb, :live_view

  alias Ecohabits.Habitos

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :habitos, [])}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Meus Hábitos")
    |> assign(:habito, nil)
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-4xl">
      <div class="flex justify-between items-center mb-8">
        <h1 class="text-3xl font-bold text-green-800">Gestão de Hábitos Sustentáveis</h1>
        <.link class="px-4 py-2 bg-green-600 text-white rounded hover:bg-green-700 transition" navigate="#">
          Novo Hábito
        </.link>
      </div>
      
      <div class="bg-white p-6 rounded-lg shadow-sm border border-gray-100 text-center text-gray-500">
        <p>A listagem de hábitos será exibida aqui futuramente.</p>
        <p class="text-sm mt-2">Módulo B - Gestão de Hábitos</p>
      </div>
    </div>
    """
  end
end
