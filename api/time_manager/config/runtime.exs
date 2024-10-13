import Config

if System.get_env("PHX_SERVER") do
  config :timemanager, TimemanagerWeb.Endpoint, server: true
end

if config_env() == :prod do
  maybe_ipv6 = if System.get_env("ECTO_IPV6") in ~w(true 1), do: [:inet6], else: []

  config :timemanager, Timemanager.Repo,
         username: System.get_env("PGUSER"),
         password: System.get_env("PGPASSWORD"),
         database: System.get_env("PGDATABASE"),
         hostname: System.get_env("PGHOST"),
         port: String.to_integer(System.get_env("PGPORT") || "5432"),
         pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
         socket_options: maybe_ipv6

  # The secret key base is used to sign/encrypt cookies and other secrets.
  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      raise """
      environment variable SECRET_KEY_BASE is missing.
      You can generate one by calling: mix phx.gen.secret
      """

  host = System.get_env("PHX_HOST") || "example.com"
  port = String.to_integer(System.get_env("PORT") || "4000")

  config :timemanager, :dns_cluster_query, System.get_env("DNS_CLUSTER_QUERY")

  config :timemanager, TimemanagerWeb.Endpoint,
         url: [host: host, port: 443, scheme: "https"],
         http: [
           ip: {0, 0, 0, 0, 0, 0, 0, 0},
           port: port
         ],
         secret_key_base: secret_key_base

  # Add any other configurations you need here
end