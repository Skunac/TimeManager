defmodule TimemanagerWeb.UserController do
  use TimemanagerWeb, :controller
  import Ecto.Query
  alias Timemanager.Repo
  alias Timemanager.User
  alias Timemanager.Team

  def index(conn, _params) do
    users = Repo.all(User) |> Repo.preload([:teams, :role])

    if Enum.empty?(users) do
      conn
      |> put_status(:not_found)
      |> json(%{error: "No users found"})
    else
      json(conn, Enum.map(users, &user_to_json/1))
    end
  end

  def create_user(conn, user_params) do
    teams = parse_teams(user_params["teams"])

    Repo.transaction(fn ->
      changeset = User.changeset(%User{}, user_params)

      with {:ok, user} <- Repo.insert(changeset),
           :ok <- associate_teams(user, teams) do
        user |> Repo.preload([:teams, :role])
      else
        {:error, changeset} -> Repo.rollback(changeset)
      end
    end)
    |> case do
         {:ok, user} ->
           conn
           |> put_status(:created)
           |> json(user_to_json(user))

         {:error, changeset} ->
           conn
           |> put_status(:unprocessable_entity)
           |> json(handle_errors(changeset))
       end
  end

  def get_user_by_id(conn, %{"id" => id}) do
    case Repo.get(User, id) |> Repo.preload([:teams, :role]) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "User not found"})

      user ->
        json(conn, user_to_json(user))
    end
  end

  def get_user_by_username_and_email(conn, params) do
    username = Map.get(params, "username")
    email = Map.get(params, "email")

    case Repo.get_by(User, username: username, email: email) |> Repo.preload([:teams, :role]) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "User not found"})

      user ->
        json(conn, user_to_json(user))
    end
  end

  def put_user_by_id(conn, %{"id" => id} = params) do
    case Repo.get(User, id) |> Repo.preload([:teams, :role]) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "User not found"})

      user ->
        Repo.transaction(fn ->
          changeset = User.changeset(user, params)

          with {:ok, updated_user} <- Repo.update(changeset),
               {:ok, updated_user} <- update_teams(updated_user, params["teams"]) do
            updated_user |> Repo.preload([:teams, :role])
          else
            {:error, changeset} -> Repo.rollback(changeset)
            {:error, :invalid_teams} -> Repo.rollback(:invalid_teams)
          end
        end)
        |> case do
             {:ok, updated_user} ->
               json(conn, user_to_json(updated_user))

             {:error, :invalid_teams} ->
               conn
               |> put_status(:unprocessable_entity)
               |> json(%{error: "One or more provided team IDs do not exist"})

             {:error, changeset} ->
               conn
               |> put_status(:unprocessable_entity)
               |> json(handle_errors(changeset))
           end
    end
  end

  def delete_user_by_id(conn, %{"id" => id}) do
    case Repo.get(User, id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "User not found"})

      user ->
        case Repo.delete(user) do
          {:ok, _deleted_user} ->
            conn
            |> put_status(:ok)
            |> json(%{message: "User deleted successfully"})

          {:error, changeset} ->
            conn
            |> put_status(:internal_server_error)
            |> json(%{error: "Failed to delete user", details: format_changeset_errors(changeset)})
        end
    end
  end

  defp associate_teams(user, teams) when is_list(teams) do
    now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)

    team_inserts = Enum.map(teams, fn team ->
      %{user_id: user.id, team_id: team.id, inserted_at: now, updated_at: now}
    end)

    case Repo.insert_all("users_teams", team_inserts) do
      {_, _} -> :ok
      _ -> {:error, "Failed to associate teams"}
    end
  end
  defp associate_teams(_user, _teams), do: :ok

  defp parse_teams(team_ids) when is_list(team_ids) do
    Repo.all(from t in Team, where: t.id in ^team_ids)
  end
  defp parse_teams(_), do: []

  defp user_to_json(user) do
    %{
      id: user.id,
      username: user.username,
      email: user.email,
      role: user.role && user.role.name,
      teams: Enum.map(user.teams, fn team -> %{id: team.id, name: team.name} end)
    }
  end

  defp update_teams(user, teams) when is_list(teams) do
    current_team_ids = MapSet.new(Enum.map(user.teams, & &1.id))
    new_team_ids = MapSet.new(parse_team_ids(teams))

    case validate_team_ids(new_team_ids) do
      :ok ->
        teams_to_add = MapSet.difference(new_team_ids, current_team_ids)
        teams_to_remove = MapSet.difference(current_team_ids, new_team_ids)

        Repo.transaction(fn ->
          # Remove old associations
          Repo.delete_all(from ut in "users_teams",
                          where: ut.user_id == ^user.id and ut.team_id in ^MapSet.to_list(teams_to_remove))

          # Add new associations
          now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
          team_inserts = Enum.map(teams_to_add, fn team_id ->
            %{user_id: user.id, team_id: team_id, inserted_at: now, updated_at: now}
          end)
          Repo.insert_all("users_teams", team_inserts)
        end)

        {:ok, Repo.preload(user, :teams, force: true)}

      :error ->
        {:error, :invalid_teams}
    end
  end

  defp update_teams(user, _teams), do: {:ok, user}

  defp parse_team_ids(team_ids) when is_list(team_ids) do
    team_ids
    |> Enum.map(fn
      id when is_binary(id) -> String.to_integer(id)
      id when is_integer(id) -> id
    end)
    |> Enum.filter(&(&1 > 0))
  end
  defp parse_team_ids(_), do: []

  defp validate_team_ids(team_ids) do
    existing_team_ids = Repo.all(from t in Team, select: t.id) |> MapSet.new()

    if MapSet.subset?(team_ids, existing_team_ids) do
      :ok
    else
      :error
    end
  end

  defp handle_errors(changeset) do
    errors = changeset.errors

    cond do
      has_error?(errors, :username, "has already been taken") ->
        %{error: :username_taken}

      has_error?(errors, :email, "has already been taken") ->
        %{error: :email_taken}

      true ->
        %{errors: format_changeset_errors(changeset)}
    end
  end

  defp has_error?(errors, field, message) do
    Enum.any?(errors, fn {key, {msg, _}} ->
      key == field and msg =~ message
    end)
  end

  defp format_changeset_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end
end