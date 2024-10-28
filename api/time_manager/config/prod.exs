import Config

# For production, we configure the host to read the PORT
# from the system environment. Therefore, you will need
# to set PORT=80 before running your server.
config :timemanager, TimemanagerWeb.Endpoint,
       url: [host: System.get_env("PHX_HOST") || "localhost", port: 80],
       http: [port: 4000],
       check_origin: false,
       cache_static_manifest: "priv/static/cache_manifest.json"

# Do not print debug messages in production
config :logger, level: :info

# Configure your database
config :timemanager, Timemanager.Repo,
       adapter: Ecto.Adapters.Postgres,
       pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10")

config :timemanager, Timemanager.Token,
       secret_key: "ZqdtglWnb2wiFdcD7FY/ZKY6U1D4eVPcb0SzBah9Q2/51tCAiRzB4+VpzmSpukqb"

config :cors_plug,
       origin: ["http://46.101.190.248:3000", "http://localhost:3000"],
       methods: ["GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"],
       headers: ["authorization", "content-type", "x-csrf-token", "x-requested-with", "accept", "origin"],
       max_age: 86400,
       credentials: true,
       expose: ["*"]

config :timemanager, TimemanagerWeb.Endpoint,
       url: [host: System.get_env("PHX_HOST") || "localhost", port: 80],
       http: [port: 4000],
       check_origin: false,
       cache_static_manifest: "priv/static/cache_manifest.json"

# Configures Swoosh API Client
config :swoosh, api_client: Swoosh.ApiClient.Finch, finch_name: Timemanager.Finch

# Disable Swoosh Local Memory Storage
config :swoosh, local: false

# Force SSL in production
# Uncomment the following line if you want to force SSL in production
# config :timemanager, TimemanagerWeb.Endpoint, force_ssl: [hsts: true]

# Set server to true if you want to start the server automatically
config :timemanager, TimemanagerWeb.Endpoint, server: true