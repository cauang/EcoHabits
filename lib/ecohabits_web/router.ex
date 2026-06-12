defmodule EcohabitsWeb.Router do
  use EcohabitsWeb, :router

  import EcohabitsWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {EcohabitsWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_scope_for_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  # --- ROTAS PÚBLICAS ---
  scope "/", EcohabitsWeb do
    pipe_through :browser

    get "/", PageController, :home
    live "/habitos", HabitoLive.Index, :index
    live "/habitos/novo", HabitoLive.Index, :new
    live "/habitos/:id/editar", HabitoLive.Index, :edit
    
  end

  # Rotas de desenvolvimento (Dashboard e Mailbox)
  if Application.compile_env(:ecohabits, :dev_routes) do
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: EcohabitsWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  # --- ROTAS PROTEGIDAS (Exigem autenticação e usam ganchos específicos) ---
  scope "/", EcohabitsWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
                 on_mount: [{EcohabitsWeb.UserAuth, :require_authenticated}] do

      live "/habitos", HabitoLive.Index, :index
      live "/habitos/novo", HabitoLive.Index, :new
      live "/habitos/:id/editar", HabitoLive.Index, :edit

      # Rota ajustada para bater com o botão amigável do Figma (/perfil)
      live "/perfil", UserLive.UserProfileLive, :index
      live "/users/profile", UserLive.UserProfileLive, :index

      live "/users/settings", UserLive.Settings, :edit
      live "/users/settings/confirm-email/:token", UserLive.Settings, :confirm_email
    end

    post "/users/update-password", UserSessionController, :update_password
  end

  # --- ROTAS DE AUTENTICAÇÃO (Acessíveis pelo pipeline browser) ---
  scope "/", EcohabitsWeb do
    pipe_through [:browser]

    live_session :current_user,
                 on_mount: [{EcohabitsWeb.UserAuth, :mount_current_scope}] do
      live "/users/register", UserLive.Registration, :new
      # Deixamos o Confirmation se você usar link mágico, mas removemos o LiveView de Login daqui!
      live "/users/log-in/:token", UserLive.Confirmation, :new
    end

    # --- DEFININDO A SEGUNDA TELA COMO A TELA OFICIAL DE LOGIN ---
    # Agora o GET aponta para o controller tradicional (a segunda tela)
    get "/users/log-in", UserSessionController, :new
    post "/users/log-in", UserSessionController, :create
    delete "/users/log-out", UserSessionController, :delete
  end
end