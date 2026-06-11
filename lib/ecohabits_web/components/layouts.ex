defmodule EcohabitsWeb.Layouts do
  @moduledoc """
  This module holds layouts and related functionality
  used by your application.
  """
  use EcohabitsWeb, :html

  embed_templates "layouts/*"

  attr :flash, :map, required: true, doc: "the map of flash messages"
  attr :current_scope, :map, default: nil, doc: "the current scope"
  slot :inner_block, required: true

  def app(assigns) do
    ~H"""
    <div class="min-h-screen bg-[#f4fbf8]">
      <header class="bg-white border-b border-gray-100">
        <div class="max-w-7xl mx-auto px-6 lg:px-8">
          <div class="flex justify-between h-20 items-center">

            <div class="flex items-center gap-2">
              <div class="bg-white border border-emerald-100 rounded-full p-1 flex items-center justify-center w-10 h-10 shadow-sm">
                <img src={~p"/images/logo.svg"} alt="EcoHabits Logo" class="w-full h-full object-contain" />
              </div>
              <span class="text-2xl font-bold text-emerald-800 tracking-tight">EcoHabits</span>
            </div>

            <nav class="flex space-x-4 items-center">
              <%= if assigns[:current_scope] && assigns[:current_scope].user do %>
                <.link href={~p"/"} class="flex items-center gap-2 px-4 py-2 text-gray-600 hover:text-emerald-600 font-medium rounded-xl transition-colors">
                  <.icon name="hero-chart-bar" class="w-5 h-5" /> Dashboard
                </.link>
                <.link href={~p"/habitos"} class="flex items-center gap-2 px-4 py-2 text-gray-600 hover:text-emerald-600 font-medium rounded-xl transition-colors">
                  <.icon name="hero-queue-list" class="w-5 h-5" /> Hábitos
                </.link>
                <.link href="#" class="flex items-center gap-2 px-4 py-2 text-gray-600 hover:text-emerald-600 font-medium rounded-xl transition-colors">
                  <.icon name="hero-users" class="w-5 h-5" /> Comunidade
                </.link>

                <.link href={~p"/users/settings"} class="text-xs text-gray-400 hover:text-gray-600 px-2">
                  { @current_scope.user.email }
                </.link>

                <.link
                  href={~p"/perfil"}
                  class="flex items-center gap-2 px-5 py-2.5 text-[#009b74] bg-[#e6f4f0] hover:bg-[#d8ede7] font-bold rounded-xl transition-all shadow-sm"
                >
                  <.icon name="hero-user" class="w-5 h-5" /> Perfil
                </.link>

                <.link
                  href={~p"/users/log-out"}
                  method="delete"
                  class="flex items-center gap-2 px-4 py-2 text-red-500 hover:text-red-600 font-medium rounded-xl transition-colors text-sm"
                >
                  Sair
                </.link>
              <% else %>
                <.link href={~p"/users/log-in"} class="flex items-center gap-2 px-6 py-2.5 text-white bg-emerald-600 hover:bg-emerald-700 font-medium rounded-xl transition-colors shadow-sm">
                  Entrar
                </.link>
              <% end %>
            </nav>

          </div>
        </div>
      </header>

      <main class="py-8">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          {render_slot(@inner_block)}
        </div>
      </main>

      <.flash_group id="flash-group" flash={@flash} />
    </div>
    """
  end

  def flash_group(assigns) do
    ~H"""
    <div id={@id} aria-live="polite">
      <.flash kind={:info} flash={@flash} />
      <.flash kind={:error} flash={@flash} />

      <.flash
        id="client-error"
        kind={:error}
        title={gettext("We can't find the internet")}
        phx-disconnected={show(".phx-client-error #client-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#client-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>

      <.flash
        id="server-error"
        kind={:error}
        title={gettext("Something went wrong!")}
        phx-disconnected={show(".phx-server-error #server-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#server-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>
    </div>
    """
  end

  def theme_toggle(assigns) do
    ~H"""
    <div class="card relative flex flex-row items-center border-2 border-base-300 bg-base-300 rounded-full">
      <div class="absolute w-1/3 h-full rounded-full border-1 border-base-200 bg-base-100 brightness-200 left-0 [[data-theme=light]_&]:left-1/3 [[data-theme=dark]_&]:left-2/3 transition-[left]" />

      <button class="flex p-2 cursor-pointer w-1/3" phx-click={JS.dispatch("phx:set-theme")} data-phx-theme="system">
        <.icon name="hero-computer-desktop-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>

      <button class="flex p-2 cursor-pointer w-1/3" phx-click={JS.dispatch("phx:set-theme")} data-phx-theme="light">
        <.icon name="hero-sun-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>

      <button class="flex p-2 cursor-pointer w-1/3" phx-click={JS.dispatch("phx:set-theme")} data-phx-theme="dark">
        <.icon name="hero-moon-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>
    </div>
    """
  end
end