defmodule EcohabitsWeb.DashboardLive do
  use EcohabitsWeb, :live_view

  alias Ecohabits.Habitos

  @impl true
  def mount(_params, _session, socket) do
    user = socket.assigns.current_scope.user
    stats = Habitos.dashboard_stats(user.id)

    socket =
      socket
      |> assign(:page_title, "Dashboard")
      |> assign(:active_nav, "dashboard")
      |> assign(:stats, stats)
      |> assign(:recent_checkins, stats.recent_checkins)

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope} pontuacao_semanal={@stats.total_points} active_nav={@active_nav}>
      <div class="space-y-6">
        <section class="space-y-3">
          <div>
            <h1 class="text-3xl text-gray-800 font-semibold">Dashboard</h1>
            <p class="text-gray-600 mt-1 max-w-2xl">Acompanhe seu progresso e impacto sustentável com métricas claras, check-ins recentes e metas semanais.</p>
          </div>
        </section>

        <section class="grid md:grid-cols-2 lg:grid-cols-4 gap-6">
          <div class="bg-gradient-to-br from-emerald-500 to-teal-600 rounded-2xl shadow-lg p-6 text-white">
            <div class="flex items-center justify-between mb-4">
              <div class="w-12 h-12 bg-white/20 rounded-full flex items-center justify-center">
                <.icon name="hero-trophy" class="w-7 h-7" />
              </div>
              <.icon name="hero-trending-up" class="w-5 h-5 opacity-80" />
            </div>
            <div class="text-3xl mb-1"><%= @stats.total_points %></div>
            <div class="text-emerald-100 text-sm">Pontos Totais</div>
          </div>

          <div class="bg-white rounded-2xl shadow-lg p-6">
            <div class="flex items-center justify-between mb-4">
              <div class="w-12 h-12 bg-amber-100 rounded-full flex items-center justify-center">
                <.icon name="hero-fire" class="w-7 h-7 text-amber-600" />
              </div>
              <span class="text-amber-600 text-sm">+2 esta semana</span>
            </div>
            <div class="text-3xl text-gray-800 mb-1"><%= @stats.current_streak %></div>
            <div class="text-gray-600 text-sm">Sequência Atual</div>
          </div>

          <div class="bg-white rounded-2xl shadow-lg p-6">
            <div class="flex items-center justify-between mb-4">
              <div class="w-12 h-12 bg-blue-100 rounded-full flex items-center justify-center">
                <.icon name="hero-fire" class="w-7 h-7 text-blue-600" />
              </div>
              <span class="text-blue-600 text-sm"><%= safe_percent(@stats.monthly_checkins, 143) %>%</span>
            </div>
            <div class="text-3xl text-gray-800 mb-1"><%= @stats.monthly_checkins || 0 %>/143</div>
            <div class="text-gray-600 text-sm">Check-ins este mês</div>
          </div>

          <div class="bg-white rounded-2xl shadow-lg p-6">
            <div class="flex items-center justify-between mb-4">
              <div class="w-12 h-12 bg-purple-100 rounded-full flex items-center justify-center">
                <.icon name="hero-calendar-days" class="w-7 h-7 text-purple-600" />
              </div>
              <span class="text-purple-600 text-sm">Nível 8</span>
            </div>
            <div class="text-3xl text-gray-800 mb-1"><%= @stats.active_days %></div>
            <div class="text-gray-600 text-sm">Dias Ativos</div>
          </div>
        </section>

        <section class="grid lg:grid-cols-2 gap-6">
          <div class="bg-white rounded-2xl shadow-lg p-6">
            <div class="flex items-center justify-between mb-6">
              <h3 class="text-xl text-gray-800">Pontos Esta Semana</h3>
              <div class="flex items-center gap-2 text-emerald-600">
                <.icon name="hero-trending-up" class="w-5 h-5" />
                <span class="text-sm">+15% vs. semana passada</span>
              </div>
            </div>

            <div class="space-y-4">
              <%= for item <- @stats.weekly_data do %>
                <div class="space-y-2">
                  <div class="flex items-center justify-between text-sm text-gray-600">
                    <span><%= item.day %></span>
                    <span><%= item.points %> pts</span>
                  </div>
                  <div class="w-full h-4 bg-gray-100 rounded-full overflow-hidden">
                    <div class="h-full rounded-full bg-gradient-to-r from-emerald-500 to-teal-600" style={"width: #{weekly_bar_width(item.points, @stats.weekly_data)}%"}></div>
                  </div>
                </div>
              <% end %>
            </div>
          </div>

          <div class="bg-white rounded-2xl shadow-lg p-6">
            <div class="flex items-center justify-between mb-6">
              <h3 class="text-xl text-gray-800">Tendência Mensal</h3>
              <div class="text-sm text-gray-600">Últimas 4 semanas</div>
            </div>

            <div class="space-y-4">
              <%= for item <- @stats.monthly_data do %>
                <div class="space-y-2">
                  <div class="flex items-center justify-between text-sm text-gray-700 mb-2">
                    <span><%= item.week %></span>
                    <span><%= item.points %> pts</span>
                  </div>
                  <div class="w-full bg-gray-100 rounded-full h-3">
                    <div class="h-3 rounded-full bg-emerald-500" style={"width: #{monthly_bar_width(item.points, @stats.monthly_data)}%"}></div>
                  </div>
                </div>
              <% end %>
            </div>
          </div>
        </section>

        <section class="bg-white rounded-2xl shadow-lg p-8">
          <div class="flex items-center justify-between mb-6">
            <h3 class="text-xl text-gray-800">Histórico de Check-ins</h3>
            <.link navigate={~p"/habitos"} class="text-emerald-600 hover:text-emerald-700 text-sm">Ver todos</.link>
          </div>

          <div class="space-y-3">
            <%= if Enum.empty?(@recent_checkins) do %>
              <div class="text-sm text-gray-500">Nenhum check-in recente.</div>
            <% else %>
              <%= for registro <- @recent_checkins do %>
                <div class="flex flex-col gap-4 p-4 bg-gradient-to-r from-emerald-50 to-teal-50 rounded-xl hover:from-emerald-100 hover:to-teal-100 transition-colors lg:flex-row lg:items-center lg:justify-between">
                  <div class="flex items-center gap-4">
                    <div class="w-12 h-12 bg-white rounded-full flex items-center justify-center shadow-sm">
                      <.icon name={category_icon(registro.category)} class="w-6 h-6 text-emerald-600" />
                    </div>
                    <div>
                      <div class="text-gray-800 mb-1 font-medium"><%= registro.habit %></div>
                      <div class="flex flex-wrap items-center gap-2 text-sm text-gray-600">
                        <span><%= registro.category %></span>
                        <span>•</span>
                        <span><%= registro.date %></span>
                      </div>
                    </div>
                  </div>
                  <div class="flex flex-col sm:flex-row sm:items-center gap-3">
                    <div class="flex items-center gap-2 bg-amber-100 px-3 py-1 rounded-full">
                      <.icon name="hero-fire" class="w-4 h-4 text-amber-600" />
                      <span class="text-sm text-amber-700"><%= registro.streak %> dias</span>
                    </div>
                    <div class="flex items-center gap-1 text-emerald-600 font-semibold">
                      <.icon name="hero-trophy" class="w-5 h-5" />
                      <span>+<%= registro.points %></span>
                    </div>
                  </div>
                </div>
              <% end %>
            <% end %>
          </div>
        </section>

        <section class="bg-white rounded-2xl shadow-lg p-8">
          <h3 class="text-xl text-gray-800 mb-6">Metas da Semana</h3>
          <div class="space-y-4">
            <%= goal_row("Completar 20 check-ins", @stats.monthly_checkins, 20) %>
            <%= goal_row("Atingir 500 pontos", @stats.total_points, 500) %>
            <%= goal_row("Manter sequência de 14 dias", @stats.current_streak, 14) %>
          </div>
        </section>
      </div>
    </Layouts.app>
    """
  end

  defp weekly_bar_width(points, weekly_data) do
    max_points = weekly_data |> Enum.map(& &1.points) |> Enum.max(fn -> 1 end)
    min(max(safe_percent(points, max_points), 10), 100)
  end

  defp monthly_bar_width(points, monthly_data) do
    max_points = monthly_data |> Enum.map(& &1.points) |> Enum.max(fn -> 1 end)
    min(max(safe_percent(points, max_points), 10), 100)
  end

  defp goal_row(label, value, target) do
    percent = min(safe_percent(value || 0, target), 100)

    assigns = %{label: label, value: value || 0, target: target, percent: percent}

    ~H"""
    <div>
      <div class="flex items-center justify-between mb-2">
        <span class="text-gray-700"><%= @label %></span>
        <span class="text-sm text-gray-600"><%= min(@value, @target) %>/ <%= @target %></span>
      </div>
      <div class="w-full bg-gray-200 rounded-full h-2">
        <div class="bg-gradient-to-r from-emerald-500 to-teal-600 rounded-full h-2" style={"width: #{@percent}%"}></div>
      </div>
    </div>
    """
  end

  defp safe_percent(numerator, denominator) when is_integer(numerator) and is_integer(denominator) and denominator > 0 do
    div(numerator * 100, denominator)
  end

  defp safe_percent(_, _), do: 0

  defp category_icon("Alimentação"), do: "hero-cake"
  defp category_icon("Transporte"), do: "hero-truck"
  defp category_icon("Energia"), do: "hero-bolt"
  defp category_icon("Água"), do: "hero-beaker"
  defp category_icon("Resíduos"), do: "hero-arrow-path-rounded-square"

  defp category_icon(c) when is_binary(c) do
    # Fallback normalizando caso venha sem acento ou minúsculo
    normalized = String.downcase(c)
    cond do
      String.contains?(normalized, "alimenta") -> "hero-cake"
      String.contains?(normalized, "transport") -> "hero-truck"
      String.contains?(normalized, "energia") -> "hero-bolt"
      String.contains?(normalized, "agua") or String.contains?(normalized, "água") -> "hero-beaker"
      String.contains?(normalized, "residuos") or String.contains?(normalized, "resíduos") -> "hero-arrow-path-rounded-square"
      true -> "hero-leaf"
    end
  end

  defp category_icon(_), do: "hero-leaf"
end
