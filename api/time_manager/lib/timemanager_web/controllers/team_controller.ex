defmodule TimemanagerWeb.TeamController do
  use TimemanagerWeb, :controller
  alias Timemanager.Repo
  alias Timemanager.Team

  def index(conn, _params) do
    teams = Repo.all(Team)

    if Enum.empty?(teams) do
      conn
      |> put_status(:not_found)
      |> json(%{error: "No teams found"})
    else
      json(conn, Enum.map(teams, &team_to_json/1))
    end
  end

  def create(conn, params) do
    changeset = Team.changeset(%Team{}, params)

    case Repo.insert(changeset) do
      {:ok, team} ->
        conn
        |> put_status(:created)
        |> json(team_to_json(team))

      {:error, %Ecto.Changeset{errors: errors} = changeset} ->
        case errors do
          [name: {_, [constraint: :unique, constraint_name: "teams_name_index"]}] ->
            conn
            |> put_status(:conflict)
            |> json(%{error: :name_taken})

          _ ->
            conn
            |> put_status(:bad_request)
            |> json(%{errors: format_changeset_errors(changeset)})
        end
    end
  end

  def show(conn, %{"id" => id}) do
    case Repo.get(Team, id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Team not found"})

      team ->
        json(conn, team_to_json(team))
    end
  end

  def update(conn, %{"id" => id} = params) do
    case Repo.get(Team, id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Team not found"})

      team ->
        changeset = Team.changeset(team, params)

        case Repo.update(changeset) do
          {:ok, updated_team} ->
            json(conn, team_to_json(updated_team))

          {:error, changeset} ->
            conn
            |> put_status(:bad_request)
            |> json(%{errors: format_changeset_errors(changeset)})
        end
    end
  end

  def delete(conn, %{"id" => id}) do
    case Repo.get(Team, id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Team not found"})

      team ->
        case Repo.delete(team) do
          {:ok, _deleted_team} ->
            conn
            |> put_status(:ok)
            |> json(%{message: "Team deleted successfully"})

          {:error, changeset} ->
            conn
            |> put_status(:internal_server_error)
            |> json(%{error: "Failed to delete team", details: format_changeset_errors(changeset)})
        end
    end
  end

  def team_to_json(team) do
    team = Repo.preload(team, :users)
    %{
      id: team.id,
      name: team.name,
      users: Enum.map(team.users, fn user -> %{id: user.id, username: user.username} end)
    }
  end

  defp format_changeset_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end
end