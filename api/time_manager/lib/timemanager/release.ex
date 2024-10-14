# lib/timemanager/release.ex
defmodule Timemanager.Release do
  @app :timemanager

  def migrate do
    load_app()

    for repo <- repos() do
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
    end
  end

  def rollback(repo, version) do
    load_app()
    {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :down, to: version))
  end

  def create_db do
    load_app()

    for repo <- repos() do
      :ok = ensure_repo_created(repo)
    end
  end

  defp ensure_repo_created(repo) do
    IO.puts("Create #{inspect(repo)} database if it doesn't exist")

    config = Keyword.merge(repo.config,
      username: System.get_env("PGUSER"),
      password: System.get_env("PGPASSWORD"),
      database: System.get_env("PGDATABASE"),
      hostname: System.get_env("PGHOST"),
      port: String.to_integer(System.get_env("PGPORT") || "5432")
    )

    case repo.__adapter__.storage_up(config) do
      :ok -> :ok
      {:error, :already_up} -> :ok
      {:error, term} -> {:error, term}
    end
  end

  defp repos do
    Application.fetch_env!(@app, :ecto_repos)
  end

  defp load_app do
    Application.load(@app)
  end
end