import Config

# For production, we configure the host to read the PORT
# from the system environment. Therefore, you will need
# to set PORT=80 before running your server.
config :timemanager, TimemanagerWeb.Endpoint,
       url: [host: System.get_env("PHX_HOST") || "example.com", port: 80],
       cache_static_manifest: "priv/static/cache_manifest.json"

# Do not print debug messages in production
config :logger, level: :info

# Configure your database
config :timemanager, Timemanager.Repo,
       adapter: Ecto.Adapters.Postgres,
       pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10")

# CORS configuration
config :cors_plug,
       origin: [System.get_env("FRONTEND_URL") || "http://localhost:3000"],
       methods: ["GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"],
       headers: ["Authorization", "Content-Type", "Accept", "Origin", "User-Agent", "DNT","Cache-Control", "X-Mx-ReqToken", "Keep-Alive", "X-Requested-With", "If-Modified-Since", "X-CSRF-Token"],
       max_age: 86400,
       credentials: true

# Configures Swoosh API Client
config :swoosh, api_client: Swoosh.ApiClient.Finch, finch_name: Timemanager.Finch

# Disable Swoosh Local Memory Storage
config :swoosh, local: false

# Force SSL in production
# Uncomment the following line if you want to force SSL in production
# config :timemanager, TimemanagerWeb.Endpoint, force_ssl: [hsts: true]

# Set server to true if you want to start the server automatically
config :timemanager, TimemanagerWeb.Endpoint, server: true