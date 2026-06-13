defmodule EcohabitsWeb.UserLive.UserProfileLive do
  use EcohabitsWeb, :live_view

  alias Ecohabits.Accounts

  @impl true
  def mount(_params, _session, socket) do
    user = socket.assigns.current_scope.user
    changeset = Accounts.change_user_profile(user)

    if connected?(socket) do
      Phoenix.PubSub.subscribe(Ecohabits.PubSub, "user_profile:#{user.id}")
    end

    {:ok,
     socket
     |> assign(:page_title, "Meu Perfil")
     |> assign(:active_nav, "perfil")
     |> assign(:pontuacao_semanal, user.points || 0)
     |> assign(:show_profile_form, false)
     |> assign_form(changeset)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope} pontuacao_semanal={@pontuacao_semanal} active_nav={@active_nav}>
      <div class="space-y-6 bg-emerald-50 p-8">
        <div class="space-y-2">
          <h1 class="text-3xl font-semibold text-slate-950">Meu Perfil</h1>
          <p class="max-w-2xl text-sm leading-6 text-slate-900">Veja e atualize seus dados, acompanhe sua pontuação e suas últimas atividades.</p>
        </div>

        <div class="grid gap-6 xl:grid-cols-[1.5fr_0.85fr]">
          <div class="rounded-[32px] border border-slate-200/80 bg-white p-8 shadow-sm">
            <div class="flex flex-col gap-6 lg:flex-row lg:items-center lg:justify-between">
              <div class="flex items-center gap-4">
                <div class="flex h-20 w-20 items-center justify-center rounded-full bg-emerald-500 text-3xl font-semibold text-white">
                  {String.slice(@current_scope.user.name || "MJ", 0, 2) |> String.upcase()}
                </div>
                <div>
                  <p class="text-xl font-semibold text-slate-950">{@current_scope.user.name || "Maria João Silva"}</p>
                  <p class="text-sm text-slate-900">{@current_scope.user.email || "mariajsilva@email.com"}</p>
                </div>
              </div>

              <button phx-click="show_profile_form" type="button" class="inline-flex items-center rounded-full border border-slate-200 bg-slate-50 px-4 py-2 text-sm font-semibold text-slate-700 transition hover:bg-slate-100">
                Editar Perfil
              </button>
            </div>

            <%= if @show_profile_form do %>
              <div class="mt-8 rounded-3xl border border-slate-200/80 bg-white p-6 shadow-sm">
                <div class="flex items-center justify-between gap-4">
                  <div>
                    <p class="text-lg font-semibold text-slate-900">Editar Perfil</p>
                    <p class="text-sm text-slate-500">Altere apenas os campos necessários.</p>
                  </div>
                  <button phx-click="hide_profile_form" type="button" class="text-sm font-semibold text-emerald-600 transition hover:text-emerald-700">Fechar</button>
                </div>

                <.form for={@form} id="profile-form" phx-change="validate" phx-submit="save" class="mt-6 space-y-4">
                  <div>
                    <p class="mb-2 text-xs font-semibold uppercase tracking-[0.18em] text-slate-500">Nome</p>
                    <.input field={@form[:name]} type="text" class="w-full rounded-2xl border border-slate-200 bg-slate-50 px-4 py-3 text-slate-900 focus:border-emerald-500 focus:ring-2 focus:ring-emerald-100" />
                  </div>
                  <div>
                    <p class="mb-2 text-xs font-semibold uppercase tracking-[0.18em] text-slate-500">Email</p>
                    <.input field={@form[:email]} type="email" class="w-full rounded-2xl border border-slate-200 bg-slate-50 px-4 py-3 text-slate-900 focus:border-emerald-500 focus:ring-2 focus:ring-emerald-100" />
                  </div>
                  <div>
                    <p class="mb-2 text-xs font-semibold uppercase tracking-[0.18em] text-slate-500">Bio</p>
                    <.input field={@form[:bio]} type="textarea" rows="4" class="w-full rounded-2xl border border-slate-200 bg-slate-50 px-4 py-3 text-slate-900 focus:border-emerald-500 focus:ring-2 focus:ring-emerald-100" />
                  </div>
                  <div class="flex items-center gap-3 pt-2">
                    <button type="submit" class="inline-flex items-center justify-center rounded-full bg-emerald-600 px-5 py-3 text-sm font-semibold text-white transition hover:bg-emerald-700">Salvar</button>
                    <button phx-click="hide_profile_form" type="button" class="inline-flex items-center justify-center rounded-full border border-slate-200 bg-slate-50 px-5 py-3 text-sm font-semibold text-slate-700 transition hover:bg-slate-100">Cancelar</button>
                  </div>
                </.form>
              </div>
            <% end %>

            <div class="mt-8 rounded-[28px] border border-slate-200/80 bg-slate-50 p-6">
              <div class="flex items-center justify-between gap-4">
                <p class="text-sm font-semibold text-slate-900">Bio</p>
                <span class="text-sm text-emerald-600">Atual</span>
              </div>
              <p class="mt-4 text-sm leading-6 text-slate-600">
                {@current_scope.user.bio || "Descreva um pouco sobre você e suas motivações sustentáveis."}
              </p>
            </div>

            <div class="mt-6 grid gap-4 sm:grid-cols-3">
              <div class="rounded-[28px] border border-slate-200/80 bg-emerald-50 p-5 shadow-sm">
                <div class="flex items-center gap-4">
                  <div class="flex h-12 w-12 items-center justify-center rounded-3xl bg-white text-emerald-700 shadow-sm">
                    <svg viewBox="0 0 24 24" class="h-6 w-6" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
                      <path d="M8 7V3" />
                      <path d="M16 7V3" />
                      <rect x="3" y="5" width="18" height="16" rx="2" ry="2" />
                      <path d="M16 13H8" />
                    </svg>
                  </div>
                  <div>
                    <p class="text-2xl font-semibold text-slate-950">127</p>
                    <p class="text-sm text-slate-600">Dias ativos</p>
                  </div>
                </div>
              </div>

              <div class="rounded-[28px] border border-slate-200/80 bg-amber-50 p-5 shadow-sm">
                <div class="flex items-center gap-4">
                  <div class="flex h-12 w-12 items-center justify-center rounded-3xl bg-white text-amber-700 shadow-sm">
                    <svg viewBox="0 0 24 24" class="h-6 w-6" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
                      <path d="M12 2L15 8L22 9L17 14L18 21L12 18L6 21L7 14L2 9L9 8L12 2Z" />
                    </svg>
                  </div>
                  <div>
                    <p class="text-2xl font-semibold text-slate-950">15</p>
                    <p class="text-sm text-slate-600">Conquistas</p>
                  </div>
                </div>
              </div>

              <div class="rounded-[28px] border border-slate-200/80 bg-sky-50 p-5 shadow-sm">
                <div class="flex items-center gap-4">
                  <div class="flex h-12 w-12 items-center justify-center rounded-3xl bg-white text-sky-700 shadow-sm">
                    <svg viewBox="0 0 24 24" class="h-6 w-6" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
                      <circle cx="12" cy="12" r="10" />
                      <circle cx="12" cy="12" r="6" />
                      <circle cx="12" cy="12" r="2" />
                    </svg>
                  </div>
                  <div>
                    <p class="text-2xl font-semibold text-slate-950">89%</p>
                    <p class="text-sm text-slate-600">Taxa de sucesso</p>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <div class="rounded-[32px] bg-gradient-to-br from-emerald-600 via-emerald-600 to-emerald-500 p-8 shadow-sm text-white">
            <div class="flex items-center justify-between gap-4">
              <div>
                <p class="text-sm uppercase tracking-[0.2em] text-emerald-100/80">Pontuação total</p>
                <p class="mt-3 text-4xl font-semibold">{@current_scope.user.points || 0}</p>
              </div>
              <div class="flex h-14 w-14 items-center justify-center rounded-3xl bg-white/10 text-white shadow-sm ring-1 ring-white/20">
                <.icon name="hero-trophy" class="w-6 h-6" />
              </div>
            </div>

            <div class="mt-8 rounded-3xl bg-white/10 p-4 text-sm">
              <div class="flex items-center justify-between text-white/90">
                <span>Nível atual</span>
                <span class="font-semibold">Eco Guardião</span>
              </div>
              <div class="mt-4 h-2 rounded-full bg-white/20">
                <div class="h-2 w-[70%] rounded-full bg-emerald-200"></div>
              </div>
              <div class="mt-4 flex items-center justify-between text-white/90">
                <span>Próximo nível</span>
                <span class="font-semibold">1.453 pontos</span>
              </div>
            </div>

            <div class="mt-6 border-t border-white/20 pt-6 text-sm text-white">
              <p class="text-white font-semibold">Esta semana</p>
              <div class="mt-4 rounded-3xl bg-white/10 p-4 text-white">
                <div class="text-3xl font-semibold">+42</div>
                <div class="mt-1 text-sm font-medium text-white/80">pontos</div>
              </div>
            </div>
          </div>
        </div>

        <div class="rounded-[32px] border border-slate-200/80 bg-white p-8 shadow-sm text-slate-950">
          <div class="flex items-center justify-between">
            <div>
              <h2 class="text-xl font-semibold text-slate-950">Atividades Recentes</h2>
              <p class="text-sm text-slate-900">Acompanhe suas últimas ações sustentáveis.</p>
            </div>
            <span class="text-sm text-slate-900">Atualizado</span>
          </div>

          <div class="mt-6 space-y-4">
            <%= for activity <- recent_activities() do %>
              <div class="flex items-center justify-between gap-4 rounded-3xl border border-slate-200/80 bg-slate-50 p-4">
                <div class="flex items-center gap-4">
                  <div class="flex h-11 w-11 items-center justify-center rounded-full bg-emerald-100 text-emerald-700 shadow-sm ring-1 ring-emerald-200">
                    <svg viewBox="0 0 48 48" class="h-5 w-5 text-emerald-700" fill="none" xmlns="http://www.w3.org/2000/svg" aria-hidden="true">
                      <path d="M22 40C18.4881 40.0106 15.1005 38.701 12.509 36.3308C9.91752 33.9607 8.31149 30.7031 8.00943 27.2042C7.70737 23.7053 8.73134 20.2207 10.8783 17.4415C13.0252 14.6622 16.1382 12.7914 19.6 12.2C31 10 34 8.96 38 4C40 8 42 12.36 42 20C42 31 32.44 40 22 40Z" stroke="currentColor" stroke-width="4" stroke-linecap="round" stroke-linejoin="round" />
                      <path d="M4 42C4 36 7.7 31.28 14.16 30C19 29.04 24 26 26 24" stroke="currentColor" stroke-width="4" stroke-linecap="round" stroke-linejoin="round" />
                    </svg>
                  </div>
                  <div>
                    <p class="font-semibold text-slate-900">{activity.title}</p>
                    <p class="text-sm text-slate-500">{activity.subtitle}</p>
                  </div>
                </div>
                <span class="text-sm font-semibold text-emerald-600">{activity.points}</span>
              </div>
            <% end %>
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end

  defp recent_activities do
    [
      %{title: "Usar garrafa reutilizável", subtitle: "Há 2 horas • Resíduos", points: "+15"},
      %{title: "Transporte ativo (bicicleta)", subtitle: "Ontem • Transporte", points: "+25"},
      %{title: "Refeição vegetariana", subtitle: "Ontem • Alimentação", points: "+20"},
      %{title: "Economizar água no banho", subtitle: "2 dias atrás • Água", points: "+10"},
      %{title: "Desligar aparelhos stand-by", subtitle: "3 dias atrás • Energia", points: "+15"}
    ]
  end

  @impl true
  def handle_event("show_profile_form", _, socket) do
    {:noreply, assign(socket, :show_profile_form, true)}
  end

  @impl true
  def handle_event("hide_profile_form", _, socket) do
    {:noreply, assign(socket, :show_profile_form, false)}
  end

  @impl true
  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset =
      socket.assigns.current_scope.user
      |> Accounts.change_user_profile(user_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  @impl true
  def handle_event("save", %{"user" => user_params}, socket) do
    user = socket.assigns.current_scope.user

    case Accounts.update_user_profile(user, user_params) do
      {:ok, updated_user} ->
        {:noreply,
         socket
         |> put_flash(:info, "Perfil atualizado com sucesso!")
         |> assign(:current_scope, %{socket.assigns.current_scope | user: updated_user})
         |> assign_form(Accounts.change_user_profile(updated_user))
         |> assign(:show_profile_form, false)
         |> assign(:show_edit_options, false)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  @impl true
  def handle_info({:profile_updated, updated_user}, socket) do
    new_scope = %{socket.assigns.current_scope | user: updated_user}
    {:noreply, assign(socket, :current_scope, new_scope)}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end
end
