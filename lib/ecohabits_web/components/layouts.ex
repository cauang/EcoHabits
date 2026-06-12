defmodule EcohabitsWeb.Layouts do
  @moduledoc """
  This module holds layouts and related functionality
  used by your application.
  """
  use EcohabitsWeb, :html

  # Embed all files in layouts/* within this module.
  # The default root.html.heex file contains the HTML
  # skeleton of your application, namely HTML headers
  # and other static content.
  embed_templates "layouts/*"

  @doc """
  Renders your app layout.

  This function is typically invoked from every template,
  and it often contains your application menu, sidebar,
  or similar.

  ## Examples

      <Layouts.app flash={@flash}>
        <h1>Content</h1>
      </Layouts.app>

  """
  attr :flash, :map, required: true, doc: "the map of flash messages"

  attr :current_scope, :map,
    default: nil,
    doc: "the current [scope](https://hexdocs.pm/phoenix/scopes.html)"

  attr :pontuacao_semanal, :integer, default: 0
  attr :active_nav, :string, default: nil

  slot :inner_block, required: true

  def app(assigns) do
    ~H"""
    <div class="min-h-screen bg-[#f4fbf8]">
      <header class="bg-white border-b border-gray-200">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div class="flex justify-between h-16 items-center">
            <div class="flex items-center gap-2">
              <div class="bg-white border border-teal-100 rounded-full p-1 flex items-center justify-center w-10 h-10 shadow-sm">
                <img src={~p"/images/logo.svg"} alt="EcoHabits Logo" class="w-full h-full object-contain" />
              </div>
              <span class="text-2xl font-semibold text-teal-700 tracking-tight">EcoHabits</span>
            </div>

            <nav class="hidden md:flex space-x-2">
              <.link
              navigate={~p"/dashboard"}
              class={[
                "flex items-center gap-2 px-4 py-2 font-medium rounded-lg transition-colors",
                @active_nav == "dashboard" && "bg-teal-100 text-teal-900",
                @active_nav != "dashboard" && "text-gray-600 hover:text-gray-900 hover:bg-gray-50"
              ]}
            >
              <.icon name="hero-chart-bar" class="w-5 h-5" /> Dashboard
            </.link>
            <.link
              navigate={~p"/habitos"}
              class={[
                "flex items-center gap-2 px-4 py-2 font-medium rounded-lg transition-colors",
                @active_nav == "habitos" && "bg-teal-100 text-teal-900",
                @active_nav != "habitos" && "text-gray-600 hover:text-gray-900 hover:bg-gray-50"
              ]}
            >
              <.icon name="hero-queue-list" class="w-5 h-5" /> Hábitos
            </.link>
            <.link
              navigate={~p"/comunidade"}
              class={[
                "flex items-center gap-2 px-4 py-2 font-medium rounded-lg transition-colors",
                @active_nav == "comunidade" && "bg-teal-100 text-teal-900",
                @active_nav != "comunidade" && "text-gray-600 hover:text-gray-900 hover:bg-gray-50"
              ]}
            >
              <.icon name="hero-users" class="w-5 h-5" /> Comunidade
            </.link>
              <.link navigate={~p"/users/settings"} class="flex items-center gap-2 px-4 py-2 text-gray-600 hover:text-gray-900 font-medium rounded-lg hover:bg-gray-50 transition-colors">
                <.icon name="hero-user" class="w-5 h-5" /> Perfil
              </.link>

              <%= if @current_scope && @current_scope.user do %>
                <div class="flex items-center gap-3 bg-white border border-gray-100 shadow-sm rounded-full pl-3 pr-1 py-1 ml-2">
                  <span class="text-sm font-medium text-gray-700">{ @current_scope.user.name }</span>
                  <div class="flex items-center gap-1 bg-gradient-to-r from-emerald-50 to-teal-50 border border-emerald-100 text-emerald-700 px-3 py-1.5 rounded-full text-sm font-bold shadow-inner">
                    <.icon name="hero-star-solid" class="w-4 h-4 text-emerald-500" />
                    { @current_scope.user.points || 0 } pts
                  </div>
                </div>
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

      <%= if @current_scope && @current_scope.user do %>
        <div class="fixed bottom-6 left-6 z-40">
          <.link
            href={~p"/users/log-out"}
            method="delete"
            class="flex items-center justify-center p-3 bg-white border border-gray-200 rounded-full shadow-sm text-gray-600 hover:text-gray-800 hover:bg-gray-100 hover:shadow-md transition-all group"
            title="Sair da conta"
          >
            <.icon name="hero-arrow-right-start-on-rectangle" class="w-6 h-6 group-hover:-translate-x-0.5 transition-transform" />
          </.link>
        </div>
      <% end %>

      <.flash_group flash={@flash} />
    </div>
    """
  end

  @doc """
  Shows the flash group with standard titles and content.

  ## Examples

      <.flash_group flash={@flash} />
  """
  attr :flash, :map, required: true, doc: "the map of flash messages"
  attr :id, :string, default: "flash-group", doc: "the optional id of flash container"

  def flash_group(assigns) do
    ~H"""
    <div id={@id} aria-live="polite" class="fixed bottom-6 right-6 z-50 flex flex-col gap-3 items-end pointer-events-none">
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

  @doc """
  Provides dark vs light theme toggle based on themes defined in app.css.

  See <head> in root.html.heex which applies the theme before page load.
  """
  def theme_toggle(assigns) do
    ~H"""
    <div class="card relative flex flex-row items-center border-2 border-base-300 bg-base-300 rounded-full">
      <div class="absolute w-1/3 h-full rounded-full border-1 border-base-200 bg-base-100 brightness-200 left-0 [[data-theme=light]_&]:left-1/3 [[data-theme=dark]_&]:left-2/3 transition-[left]" />

      <button
        class="flex p-2 cursor-pointer w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="system"
      >
        <.icon name="hero-computer-desktop-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>

      <button
        class="flex p-2 cursor-pointer w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="light"
      >
        <.icon name="hero-sun-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>

      <button
        class="flex p-2 cursor-pointer w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="dark"
      >
        <.icon name="hero-moon-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>
    </div>
    """
  end
end
