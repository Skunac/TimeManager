defmodule TimemanagerWeb.Router do
  use TimemanagerWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :auth do
    plug TimemanagerWeb.AuthPlug
  end

  scope "/api", TimemanagerWeb do
    pipe_through :api

    # Authentification
    post "/register", AuthController, :register
    post "/login", AuthController, :login
  end


  scope "/api", TimemanagerWeb do
    pipe_through [:api, :auth]

    # Scope Users
    scope "/users" do
      get "", UserController, :index
      get "", UserController, :get_user_by_username_and_email
      get "/:id", UserController, :get_user_by_id
      post "", UserController, :create_user
      put "/:id", UserController, :put_user_by_id
      delete "/:id", UserController, :delete_user_by_id
    end

    scope "/teams" do
      get "", TeamController, :index
      get "/:id", TeamController, :show
      post "", TeamController, :create
      put "/:id", TeamController, :update
      delete "/:id", TeamController, :delete
    end

    # Scope WorkingTime
    scope "/workingtime" do
      get "/:userID", WorkingTimeController, :index
      get "/:userID/:id", WorkingTimeController, :show
      post "/:userID", WorkingTimeController, :create
      put "/:id", WorkingTimeController, :update
      delete "/:id", WorkingTimeController, :delete
    end

    # Scope Clocks
    scope "/clocks" do
      get "", ClockController, :index
      get "/:userID", ClockController, :get_clock_by_user_id
      post "/:userID", ClockController, :create
    end
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
