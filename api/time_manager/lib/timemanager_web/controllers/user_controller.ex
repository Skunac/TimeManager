defmodule TimemanagerWeb.UserController do
  use TimemanagerWeb, :controller
  import Ecto.Query
  alias Timemanager.{Repo, User, Role, Team}

  @doc """
  Lists all users
  """
  def index(conn, _params) do
    current_user_role = conn.assigns[:current_user_role]
    current_user_id = conn.assigns[:current_user_id]

    users = case current_user_role do
      "general_manager" ->
        User
        |> Repo.all()
        |> Repo.preload([:teams, :role])

      "manager" ->
        # Get users that share any team with the manager
        query = from u in User,
                     join: ut1 in "users_teams",
                     on: ut1.user_id == u.id,
                     join: ut2 in "users_teams",
                     on: ut2.team_id == ut1.team_id,
                     where: ut2.user_id == ^current_user_id,
                     distinct: true,
                     preload: [:teams, :role]

        Repo.all(query)

      _ ->
        User
        |> where([u], u.id == ^current_user_id)
        |> Repo.all()
        |> Repo.preload([:teams, :role])
    end

    if Enum.empty?(users) do
      conn
      |> put_status(:not_found)
      |> json(%{error: "No users found"})
    else
      json(conn, Enum.map(users, &user_to_json/1))
    end
  end

  @doc """
  Creates a new user
  """
  def create(conn, user_params) do
    changeset = User.changeset(%User{}, user_params)

    case Repo.insert(changeset) do
      {:ok, user} ->
        user = Repo.preload(user, [:teams, :role])

        conn
        |> put_status(:created)
        |> json(user_to_json(user))

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: format_changeset_errors(changeset)})
    end
  end

  @doc """
  Shows a specific user
  """
  def show(conn, %{"id" => id}) do
    with {:ok, user_id} <- validate_id(id),
         %User{} = user <- Repo.get(User, user_id) |> Repo.preload([:teams, :role]) do
      json(conn, user_to_json(user))
    else
      {:error, :invalid_id} ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "Invalid user ID format"})

      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "User not found"})
    end
  end

  @doc """
  Updates a user
  """
  def update(conn, %{"id" => id} = params) do
    with {:ok, user_id} <- validate_id(id),
         %User{} = user <- Repo.get(User, user_id) |> Repo.preload([:teams, :role]),
         teams <- parse_teams(params["teams"]),
         {:ok, updated_user} <- do_update_user(user, params, teams) do

      updated_user = Repo.preload(updated_user, [:teams, :role], force: true)
      json(conn, user_to_json(updated_user))
    else
      {:error, :invalid_id} ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "Invalid user ID format"})

      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "User not found"})

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: format_changeset_errors(changeset)})
    end
  end

  @doc """
  Deletes a user
  """
  def delete(conn, %{"id" => id}) do
    with {:ok, user_id} <- validate_id(id),
         %User{} = user <- Repo.get(User, user_id),
         {:ok, _deleted} <- Repo.delete(user) do

      conn
      |> put_status(:ok)
      |> json(%{message: "User deleted successfully"})
    else
      {:error, :invalid_id} ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "Invalid user ID format"})

      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "User not found"})

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: format_changeset_errors(changeset)})
    end
  end

  @doc """
  Promotes a user to manager role
  """
  def promote(conn, %{"id" => id}) do
    with {:ok, user_id} <- validate_id(id),
         %User{} = user <- Repo.get(User, user_id) |> Repo.preload(:role),
         :ok <- validate_not_manager(user),
         %Role{} = manager_role <- Repo.get_by(Role, name: "manager"),
         {:ok, updated_user} <- update_user_role(user, manager_role),
         loaded_user <- Repo.preload(updated_user, [:teams, :role]) do

      conn
      |> put_status(:ok)
      |> json(user_to_json(loaded_user))
    else
      {:error, :already_manager} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: "User is already a manager"})

      {:error, :invalid_id} ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "Invalid user ID format"})

      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "User or manager role not found"})

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{
          error: "Failed to promote user",
          details: format_changeset_errors(changeset)
        })
    end
  end

  # Private functions

  defp validate_not_manager(%User{role: %Role{name: "manager"}}), do: {:error, :already_manager}
  defp validate_not_manager(_user), do: :ok

  defp update_user_role(user, new_role) do
    user
    |> User.role_changeset(%{role_id: new_role.id})
    |> Repo.update()
  end

  defp validate_id(id) when is_binary(id) do
    case Integer.parse(id) do
      {id, ""} when id > 0 -> {:ok, id}
      _ -> {:error, :invalid_id}
    end
  end
  defp validate_id(_), do: {:error, :invalid_id}

  defp user_to_json(%User{} = user) do
    %{
      id: user.id,
      username: user.username,
      email: user.email,
      role: (user.role && user.role.name) || "unknown",
      teams: Enum.map(user.teams || [], fn team -> %{id: team.id, name: team.name} end)
    }
  end

  defp format_changeset_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end

  defp parse_teams(teams) when is_list(teams) do
    # If teams is an empty list, return it explicitly
    if Enum.empty?(teams) do
      []
    else
      query = from(team in Team, where: team.id in ^teams)
      Repo.all(query)
    end
  end
  defp parse_teams(nil), do: nil
  defp parse_teams(_), do: nil

  defp update_user_teams(user, nil), do: {:ok, user}  # No teams in request, keep existing
  defp update_user_teams(user, teams) do              # Handle both empty and non-empty lists
    now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)

    # Always clear existing associations first
    Repo.delete_all(from(ut in "users_teams", where: ut.user_id == ^user.id))

    # Only insert new associations if teams list is not empty
    if Enum.empty?(teams) do
      {:ok, user}  # Return success with no new teams
    else
      team_inserts = Enum.map(teams, fn team ->
        %{
          user_id: user.id,
          team_id: team.id,
          inserted_at: now,
          updated_at: now
        }
      end)

      case Repo.insert_all("users_teams", team_inserts) do
        {_, _} -> {:ok, user}
        _ -> {:error, "Failed to update teams"}
      end
    end
  end

  defp do_update_user(user, params, teams) do
    Repo.transaction(fn ->
      with {:ok, updated_user} <- User.update_changeset(user, params) |> Repo.update(),
           {:ok, user_with_teams} <- update_user_teams(updated_user, teams) do
        # Force reload associations to ensure we get the updated state
        updated_user = Repo.preload(user_with_teams, [:teams, :role], force: true)
        updated_user
      else
        {:error, reason} -> Repo.rollback(reason)
      end
    end)
  end
end