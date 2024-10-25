defmodule TimemanagerWeb.Router do
  use TimemanagerWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :browser do
    plug :accepts, ["html"]
    plug :put_secure_browser_headers
  end

  pipeline :auth do
    plug TimemanagerWeb.AuthPlug
  end

  pipeline :manager_auth do
    plug TimemanagerWeb.AuthorizationPlug, [
      user_id_param: "id",
      require_manager: true,
      allow_team_access: false
    ]
  end

  # For self-access only routes
  pipeline :self_access do
    plug TimemanagerWeb.AuthorizationPlug, [
      user_id_param: "id",
      require_manager: false,
      allow_team_access: false
    ]
  end

  # For resources that allow self access and team access
  pipeline :user_resource_auth do
    plug TimemanagerWeb.AuthorizationPlug, [
      user_id_param: "userID",
      require_manager: false,
      allow_team_access: true
    ]
  end

  scope "/api", TimemanagerWeb do
    pipe_through :api

    # Authentification
    post "/register", AuthController, :register
    post "/login", AuthController, :login
  end

  scope "/api", TimemanagerWeb do
    pipe_through [:api, :auth]

    # Users scope
    scope "/users" do
      # Manager/General Manager only routes
      scope "/" do
        pipe_through :manager_auth

        get "", UserController, :index
        post "", UserController, :create
        post "/:id/promote", UserController, :promote
        put "/:id", UserController, :update
        delete "/:id", UserController, :delete
      end

      # Self-access only route
      scope "/" do
        pipe_through :self_access
        get "/:id", UserController, :show
      end
    end

    # Teams scope (manager only)
    scope "/teams" do
      pipe_through :manager_auth

      get "", TeamController, :index
      get "/:id", TeamController, :show
      post "", TeamController, :create
      put "/:id", TeamController, :update
      delete "/:id", TeamController, :delete
    end

    # Working Times scope (self or manager of team)
    scope "/workingtime" do
      pipe_through :user_resource_auth

      get "/:userID", WorkingTimeController, :index
      get "/:userID/:id", WorkingTimeController, :show
      post "/:userID", WorkingTimeController, :create
      put "/:id", WorkingTimeController, :update
      delete "/:id", WorkingTimeController, :delete
    end

    # Clocks scope (self or manager of team)
    scope "/clocks" do
      pipe_through :user_resource_auth

      get "", ClockController, :index
      get "/:userID", ClockController, :get_clock_by_user_id
      post "/:userID", ClockController, :create
    end
  end

  scope "/", TimemanagerWeb do
    pipe_through :browser
    get "/*path", PageController, :index
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:timemanager, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]

      live_dashboard "/dashboard", metrics: TimemanagerWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
