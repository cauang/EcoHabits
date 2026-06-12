defmodule EcohabitsWeb.HabitoLive.Index do
  use EcohabitsWeb, :live_view

  alias Ecohabits.Habitos
  alias Ecohabits.Habitos.Habito

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:filtro_categoria, "all")
      |> assign(:busca, "")
      |> assign(:habito_editando, nil)
      |> assign(:form, to_form(Habitos.change_habito(%Habito{})))
      |> fetch_habitos()

    {:ok, socket}
  end

  defp fetch_habitos(socket) do
    criteria = %{
      categoria_id: socket.assigns.filtro_categoria,
      busca: socket.assigns.busca,
      usuario_id: 1 # Temporário: Simulação de usuário logado
    }
    assign(socket, :habitos, Habitos.list_habitos(criteria))
  end

  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "Novo Hábito")
    |> assign(:habito_editando, nil)
    |> assign(:form, to_form(Habitos.change_habito(%Habito{})))
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    habito = Habitos.get_habito!(id)

    socket
    |> assign(:page_title, "Editar Hábito")
    |> assign(:habito_editando, habito)
    |> assign(:form, to_form(Habitos.change_habito(habito)))
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Meus Hábitos")
    |> assign(:habito_editando, nil)
    |> assign(:form, to_form(Habitos.change_habito(%Habito{})))
  end

  def handle_event("filtrar_categoria", %{"id" => id}, socket) do
    {:noreply,
     socket
     |> assign(:filtro_categoria, id)
     |> fetch_habitos()}
  end

  def handle_event("buscar", %{"busca" => busca}, socket) do
    {:noreply,
     socket
     |> assign(:busca, busca)
     |> fetch_habitos()}
  end

  def handle_event("checkin", %{"id" => id}, socket) do
    usuario_id = 1 # Temporário: Simulação de usuário logado
    habito = Habitos.get_habito!(id)

    case Habitos.fazer_checkin(id, usuario_id) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "Check-in realizado com sucesso! +#{habito.pontuacao} pontos.")
         |> fetch_habitos()}

      {:error, changeset} ->
        mensagem = if changeset.errors[:habito_id], do: "Você já fez o check-in hoje neste hábito!", else: "Não foi possível fazer o check-in."
        {:noreply, put_flash(socket, :error, mensagem)}
    end
  end

  def handle_event("save", %{"habito" => habit_params}, socket) do
    habit_params =
      habit_params
      |> Map.put("usuario_id", 1)
      |> Map.update("pontuacao", "0", fn p -> if p == "", do: "0", else: p end)

    resultado =
      if socket.assigns.habito_editando do
        Habitos.update_habito(socket.assigns.habito_editando, habit_params)
      else
        Habitos.create_habito(habit_params)
      end

    case resultado do
      {:ok, _habit} ->
        mensagem = if socket.assigns.habito_editando, do: "Hábito atualizado com sucesso.", else: "Hábito criado com sucesso."

        {:noreply,
         socket
         |> put_flash(:info, mensagem)
         |> fetch_habitos()
         |> push_patch(to: ~p"/habitos")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(Map.put(changeset, :action, :insert)))}
    end
  end

  def handle_event("deletar", %{"id" => id}, socket) do
    habito = Habitos.get_habito!(id)

    case Habitos.delete_habito(habito) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "Hábito \"#{habito.nome}\" excluído com sucesso.")
         |> fetch_habitos()}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Não foi possível excluir o hábito.")}
    end
  end

  defp border_gradient_categoria(1), do: "from-orange-400 to-orange-500"
  defp border_gradient_categoria(2), do: "from-blue-400 to-blue-500"
  defp border_gradient_categoria(3), do: "from-yellow-400 to-yellow-500"
  defp border_gradient_categoria(4), do: "from-cyan-400 to-cyan-500"
  defp border_gradient_categoria(5), do: "from-emerald-400 to-emerald-500"
  defp border_gradient_categoria(_), do: "from-green-400 to-green-500"

  defp nome_categoria(1), do: "Alimentação"
  defp nome_categoria(2), do: "Transporte"
  defp nome_categoria(3), do: "Energia"
  defp nome_categoria(4), do: "Água"
  defp nome_categoria(5), do: "Resíduos"
  defp nome_categoria(_), do: "Outros"

  defp checkin_feito?(habito) do
    is_list(habito.registros) and habito.registros != []
  end

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="space-y-6">
        <div class="flex items-center justify-between">
          <div>
            <h1 class="text-3xl text-gray-800">Meus Hábitos</h1>
            <p class="text-gray-600 mt-1">Gerencie e pratique seus hábitos sustentáveis</p>
          </div>
          <.link patch={~p"/habitos/novo"} class="flex items-center gap-2 bg-gradient-to-r from-emerald-500 to-teal-600 text-white px-6 py-3 rounded-lg hover:from-emerald-600 hover:to-teal-700 transition-all shadow-md hover:shadow-lg">
            <.icon name="hero-plus-solid" class="w-5 h-5" /> Novo Hábito
          </.link>
        </div>

        <div class="bg-white rounded-2xl shadow-lg p-6">
          <form phx-change="buscar" class="flex items-center gap-4 mb-4" onsubmit="return false;">
            <.icon name="hero-magnifying-glass" class="w-5 h-5 text-gray-400" />
            <input type="text" name="busca" value={@busca} phx-debounce="300" placeholder="Buscar hábitos..." class="flex-1 outline-none text-gray-700 bg-transparent" />
          </form>

          <div class="flex items-center gap-3 overflow-x-auto pb-2">
            <button phx-click="filtrar_categoria" phx-value-id="all" class={["flex items-center gap-2 px-4 py-2 rounded-lg whitespace-nowrap transition-all", @filtro_categoria == "all" && "bg-emerald-100 text-emerald-700 shadow-sm", @filtro_categoria != "all" && "bg-gray-100 text-gray-600 hover:bg-gray-200"]}>
              <.icon name="hero-funnel" class="w-4 h-4" /> Todos
            </button>
            <button phx-click="filtrar_categoria" phx-value-id="1" class={["flex items-center gap-2 px-4 py-2 rounded-lg whitespace-nowrap transition-all", @filtro_categoria == "1" && "bg-emerald-100 text-emerald-700 shadow-sm", @filtro_categoria != "1" && "bg-gray-100 text-gray-600 hover:bg-gray-200"]}>
              <.icon name="hero-cake" class="w-4 h-4" /> Alimentação
            </button>
            <button phx-click="filtrar_categoria" phx-value-id="2" class={["flex items-center gap-2 px-4 py-2 rounded-lg whitespace-nowrap transition-all", @filtro_categoria == "2" && "bg-emerald-100 text-emerald-700 shadow-sm", @filtro_categoria != "2" && "bg-gray-100 text-gray-600 hover:bg-gray-200"]}>
              <.icon name="hero-truck" class="w-4 h-4" /> Transporte
            </button>
            <button phx-click="filtrar_categoria" phx-value-id="3" class={["flex items-center gap-2 px-4 py-2 rounded-lg whitespace-nowrap transition-all", @filtro_categoria == "3" && "bg-emerald-100 text-emerald-700 shadow-sm", @filtro_categoria != "3" && "bg-gray-100 text-gray-600 hover:bg-gray-200"]}>
              <.icon name="hero-bolt" class="w-4 h-4" /> Energia
            </button>
            <button phx-click="filtrar_categoria" phx-value-id="4" class={["flex items-center gap-2 px-4 py-2 rounded-lg whitespace-nowrap transition-all", @filtro_categoria == "4" && "bg-emerald-100 text-emerald-700 shadow-sm", @filtro_categoria != "4" && "bg-gray-100 text-gray-600 hover:bg-gray-200"]}>
              <.icon name="hero-beaker" class="w-4 h-4" /> Água
            </button>
            <button phx-click="filtrar_categoria" phx-value-id="5" class={["flex items-center gap-2 px-4 py-2 rounded-lg whitespace-nowrap transition-all", @filtro_categoria == "5" && "bg-emerald-100 text-emerald-700 shadow-sm", @filtro_categoria != "5" && "bg-gray-100 text-gray-600 hover:bg-gray-200"]}>
              <.icon name="hero-arrow-path-rounded-square" class="w-4 h-4" /> Resíduos
            </button>
          </div>
        </div>

        <div class="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
          <%= for habito <- @habitos do %>
            <div class={["bg-white rounded-2xl shadow-lg overflow-hidden hover:shadow-xl transition-shadow", checkin_feito?(habito) && "ring-2 ring-emerald-400"]}>
              <div class={["h-2 bg-gradient-to-r", border_gradient_categoria(habito.categoria_id)]}></div>

              <div class="p-6">
                <div class="flex items-start justify-between mb-3">
                  <h3 class="text-lg text-gray-800 flex-1">{habito.nome}</h3>
                  <div class="flex items-center gap-1">
                    <.link patch={~p"/habitos/#{habito.id}/editar"} id={"editar-#{habito.id}"} class="p-2 hover:bg-gray-100 rounded-lg transition-colors">
                      <.icon name="hero-pencil" class="w-4 h-4 text-gray-500" />
                    </.link>
                    <button
                      id={"deletar-#{habito.id}"}
                      phx-click="deletar"
                      phx-value-id={habito.id}
                      data-confirm={"Tem certeza que deseja excluir o hábito \"#{habito.nome}\"?"}
                      class="p-2 hover:bg-red-50 rounded-lg transition-colors"
                    >
                      <.icon name="hero-trash" class="w-4 h-4 text-red-500" />
                    </button>
                  </div>
                </div>

                <p class="text-sm text-gray-600 mb-4">{habito.descricao}</p>

                <div class="flex items-center gap-2 mb-4">
                  <span class="text-xs bg-gray-100 text-gray-600 px-3 py-1 rounded-full">
                    {nome_categoria(habito.categoria_id)}
                  </span>
                  <div class="flex items-center gap-1 text-emerald-600">
                    <.icon name="hero-trophy" class="w-4 h-4" />
                    <span class="text-sm">+{habito.pontuacao} pts</span>
                  </div>
                </div>

                <%= if checkin_feito?(habito) do %>
                  <button class="w-full py-3 rounded-lg transition-all bg-emerald-100 text-emerald-700 cursor-default flex items-center justify-center gap-2">
                    <.icon name="hero-check" class="w-5 h-5" /> Realizado hoje
                  </button>
                <% else %>
                  <button phx-click="checkin" phx-value-id={habito.id} class="w-full py-3 rounded-lg transition-all bg-gradient-to-r from-emerald-500 to-teal-600 text-white hover:from-emerald-600 hover:to-teal-700 shadow-md hover:shadow-lg">
                    Fazer check-in
                  </button>
                <% end %>
              </div>
            </div>
          <% end %>
        </div>

        <%!-- Modal de criação / edição --%>
        <div :if={@live_action in [:new, :edit]} class="modal modal-open" id="habit-modal">
          <div class="modal-box bg-white rounded-2xl shadow-2xl max-w-md w-full p-8 border-none relative">
            <h2 class="text-2xl text-gray-800 mb-6">
              {if @live_action == :edit, do: "Editar Hábito", else: "Novo Hábito Sustentável"}
            </h2>
            <.form for={@form} id="habito-form" phx-submit="save" class="space-y-4">
              <div :if={@form.errors[:usuario_id]} class="p-3 bg-red-100 text-red-700 rounded-lg text-sm mb-4">
                <.icon name="hero-exclamation-circle" class="w-5 h-5 inline mr-1" />
                {translate_error(Enum.at(@form.errors[:usuario_id], 0) || {"Erro de usuário", []})}
              </div>

              <div>
                <label class="block text-sm text-gray-700 mb-2">Nome do hábito</label>
                <.input field={@form[:nome]} type="text" placeholder="Ex: Separar lixo reciclável" class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-emerald-500 text-gray-800" />
              </div>

              <div>
                <label class="block text-sm text-gray-700 mb-2">Descrição</label>
                <.input field={@form[:descricao]} type="textarea" placeholder="Descreva o hábito..." rows="3" class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-emerald-500 text-gray-800" />
              </div>

              <div>
                <label class="block text-sm text-gray-700 mb-2">Categoria</label>
                <.input field={@form[:categoria_id]} type="select" options={[{"Alimentação", 1}, {"Transporte", 2}, {"Energia", 3}, {"Água", 4}, {"Resíduos", 5}, {"Outros", 6}]} class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-emerald-500 text-gray-800" />
              </div>

              <div>
                <label class="block text-sm text-gray-700 mb-2">Pontuação</label>
                <.input field={@form[:pontuacao]} type="number" placeholder="10" class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-emerald-500 text-gray-800" />
              </div>

              <div class="flex gap-3 mt-6">
                <.link patch={~p"/habitos"} class="flex-1 px-6 py-3 border border-gray-300 text-gray-700 rounded-lg hover:bg-gray-50 transition-colors text-center">
                  Cancelar
                </.link>
                <button type="submit" id="habito-submit" class="flex-1 px-6 py-3 bg-gradient-to-r from-emerald-500 to-teal-600 text-white rounded-lg hover:from-emerald-600 hover:to-teal-700 transition-all shadow-md">
                  {if @live_action == :edit, do: "Salvar alterações", else: "Criar Hábito"}
                </button>
              </div>
            </.form>
          </div>
          <div class="modal-backdrop" phx-click={JS.patch(~p"/habitos")}>
            <button class="cursor-default">fechar</button>
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end
end
