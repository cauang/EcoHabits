defmodule EcohabitsWeb.FeedLive do
  use EcohabitsWeb, :live_view

  alias Ecohabits.Habitos

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(Ecohabits.PubSub, "checkins:feed")
    end

    stats = Habitos.community_stats()
    feed = Habitos.list_recent_feed()
    top = Habitos.top_contributors()

    socket =
      socket
      |> assign(:page_title, "Feed da Comunidade")
      |> assign(:active_nav, "comunidade")
      |> assign(:stats, stats)
      |> assign(:feed_items, feed)
      |> assign(:top_contributors, top)

    {:ok, socket}
  end

  @impl true
  def handle_info({:new_checkin, _habito, _user}, socket) do
    {:noreply,
     socket
     |> assign(:feed_items, Habitos.list_recent_feed())
     |> assign(:stats, Habitos.community_stats())
     |> assign(:top_contributors, Habitos.top_contributors())}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope} pontuacao_semanal={@stats.total_points} active_nav={@active_nav}>
      <div class="space-y-6">
      <div>
        <h1 class="text-3xl text-gray-800">Feed da Comunidade</h1>
        <p class="text-gray-600 mt-1">Acompanhe o impacto coletivo em tempo real</p>
      </div>

      <div class="grid md:grid-cols-4 gap-6">
        <div class="bg-gradient-to-br from-emerald-500 to-teal-600 rounded-2xl shadow-lg p-6 text-white">
          <div class="flex items-center gap-3 mb-3">
            <div class="w-10 h-10 bg-white/20 rounded-full flex items-center justify-center">
              <.icon name="hero-users" class="w-6 h-6" />
            </div>
            <div class="text-2xl"><%= @stats.members %></div>
          </div>
          <div class="text-emerald-100 text-sm">Membros Ativos</div>
        </div>

        <div class="bg-white rounded-2xl shadow-lg p-6">
          <div class="flex items-center gap-3 mb-3">
            <div class="w-10 h-10 bg-orange-100 rounded-full flex items-center justify-center">
              <.icon name="hero-fire" class="w-6 h-6 text-orange-500" />
            </div>
            <div class="text-2xl text-gray-800"><%= @stats.checkins_today %></div>
          </div>
          <div class="text-gray-600 text-sm">Check-ins Hoje</div>
        </div>

        <div class="bg-white rounded-2xl shadow-lg p-6">
          <div class="flex items-center gap-3 mb-3">
            <div class="w-10 h-10 bg-amber-100 rounded-full flex items-center justify-center">
              <.icon name="hero-trophy" class="w-6 h-6 text-amber-600" />
            </div>
            <div class="text-2xl text-gray-800"><%= @stats.total_points %></div>
          </div>
          <div class="text-gray-600 text-sm">Pontos Totais</div>
        </div>

        <div class="bg-white rounded-2xl shadow-lg p-6">
          <div class="flex items-center gap-3 mb-3">
            <div class="w-10 h-10 bg-green-100 rounded-full flex items-center justify-center">
              <.icon name="hero-globe-alt" class="w-6 h-6 text-green-600" />
            </div>
            <div class="text-2xl text-gray-800"><%= @stats.co2_reduced_today %>kg</div>
          </div>
          <div class="text-gray-600 text-sm">CO₂ Reduzido Hoje</div>
        </div>
      </div>

      <div class="grid lg:grid-cols-3 gap-6">
        <div class="lg:col-span-2 space-y-4">
          <div class="flex items-center justify-between">
            <h2 class="text-xl text-gray-800">Atividade Recente</h2>
            <div class="flex items-center gap-2 text-emerald-600">
              <div class="w-2 h-2 bg-emerald-600 rounded-full animate-pulse"></div>
              <span class="text-sm">Ao vivo</span>
            </div>
          </div>

          <div class="space-y-3">
            <%= for item <- @feed_items do %>
              <div class="bg-white rounded-xl shadow-md p-5 hover:shadow-lg transition-shadow">
                <div class="flex items-start gap-4">
                  <div class={"w-12 h-12 rounded-full flex items-center justify-center text-white text-sm bg-gradient-to-br " <> color_class(item.color)}>
                    <%= item.avatar %>
                  </div>

                  <div class="flex-1">
                    <div class="flex items-start justify-between mb-2">
                      <div>
                        <div class="text-gray-800"><%= item.user %></div>
                        <div class="text-sm text-gray-500"><%= item.time %></div>
                      </div>
                      <div class="flex items-center gap-1 text-emerald-600">
                        <.icon name="hero-trophy" class="w-4 h-4" />
                        <span>+<%= item.points %></span>
                      </div>
                    </div>

                    <div class="flex items-center gap-2 mb-2">
                      <.icon name="hero-leaf" class="w-4 h-4 text-emerald-600" />
                      <span class="text-gray-700"><%= item.habit %></span>
                    </div>

                    <div class="flex items-center gap-3 text-sm">
                      <span class="bg-gray-100 text-gray-600 px-3 py-1 rounded-full"><%= item.category %></span>
                      <div class="flex items-center gap-1 text-amber-600">
                        <.icon name="hero-fire" class="w-4 h-4" />
                        <span><%= item.streak %> dias</span>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            <% end %>
          </div>

          <button class="w-full py-3 border-2 border-dashed border-gray-300 text-gray-600 rounded-xl hover:border-emerald-400 hover:text-emerald-600 transition-colors">
            Carregar mais atividades
          </button>
        </div>

        <div class="space-y-6">
          <div class="bg-white rounded-2xl shadow-lg p-6">
            <div class="flex items-center gap-2 mb-6">
              <.icon name="hero-trending-up" class="w-5 h-5 text-emerald-600" />
              <h3 class="text-lg text-gray-800">Top Contribuidores</h3>
            </div>

            <div class="space-y-4">
              <%= for contributor <- @top_contributors do %>
                <div class="flex items-center gap-3 p-3 bg-gradient-to-r from-emerald-50 to-teal-50 rounded-lg transition-colors">
                  <div class={"w-8 h-8 rounded-full flex items-center justify-center text-sm " <> rank_class(contributor.rank)}>
                    <%= contributor.rank %>
                  </div>
                  <div class="w-10 h-10 bg-gradient-to-br from-emerald-400 to-teal-600 rounded-full flex items-center justify-center text-white text-sm">
                    <%= initials(contributor.name) %>
                  </div>
                  <div class="flex-1 min-w-0">
                    <div class="text-sm text-gray-800 truncate"><%= contributor.name %></div>
                    <div class="text-xs text-gray-600"><%= contributor.points %> pts</div>
                  </div>
                </div>
              <% end %>
            </div>
          </div>

          <div class="bg-gradient-to-br from-green-500 to-emerald-600 rounded-2xl shadow-lg p-6 text-white">
            <h3 class="text-lg mb-4">Impacto Coletivo</h3>
            <div class="space-y-4">
              <div>
                <div class="text-sm opacity-90 mb-1">Esta Semana</div>
                <div class="text-2xl">5.2 toneladas</div>
                <div class="text-sm opacity-80">CO₂ evitado</div>
              </div>
              <div class="h-px bg-white/20"></div>
              <div>
                <div class="text-sm opacity-90 mb-1">Equivalente a</div>
                <div class="space-y-1 text-sm">
                  <div>🌳 260 árvores plantadas</div>
                  <div>🚗 21.000 km não percorridos</div>
                  <div>💧 850.000 litros de água economizados</div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    </Layouts.app>
    """
  end

  defp color_class("emerald"), do: "from-emerald-400 to-emerald-600"
  defp color_class("blue"), do: "from-blue-400 to-blue-600"
  defp color_class("green"), do: "from-green-400 to-green-600"
  defp color_class("orange"), do: "from-orange-400 to-orange-600"
  defp color_class("cyan"), do: "from-cyan-400 to-cyan-600"
  defp color_class(_), do: "from-yellow-400 to-yellow-600"

  defp rank_class(1), do: "bg-gradient-to-br from-yellow-400 to-yellow-600 text-white"
  defp rank_class(2), do: "bg-gradient-to-br from-gray-300 to-gray-500 text-white"
  defp rank_class(3), do: "bg-gradient-to-br from-orange-400 to-orange-600 text-white"
  defp rank_class(_), do: "bg-emerald-200 text-emerald-700"

  defp initials(name) when is_binary(name) do
    name
    |> String.split()
    |> Enum.map(&String.first/1)
    |> Enum.take(2)
    |> Enum.join("")
  end
end
