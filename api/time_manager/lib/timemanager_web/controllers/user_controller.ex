defmodule TimemanagerWeb.UserController do
  use TimemanagerWeb, :controller
  alias Timemanager.Repo
  alias Timemanager.User

  def index(conn, _params) do
    users = Repo.all(User)

    if Enum.empty?(users) do
      conn
      |> put_status(:not_found)
      |> json(%{error: "No users found"})
    else
      json(conn, Enum.map(users, &user_to_json/1))
    end
  end

  def create_user(conn, user_params) do
    changeset = User.changeset(%User{}, user_params)

    case Repo.insert(changeset) do
      {:ok, user} ->
        conn
        |> put_status(:created)
        |> json(user_to_json(user))

      {:error, %Ecto.Changeset{errors: errors} = changeset} ->
        case errors do
          [username: {_, [constraint: :unique, constraint_name: "users_username_index"]}] ->
            conn
            |> put_status(:conflict)
            |> json(%{error: "Username already taken"})

          [email: {_, [constraint: :unique, constraint_name: "users_email_index"]}] ->
            conn
            |> put_status(:conflict)
            |> json(%{error: "Email already in use"})

          _ ->
            conn
            |> put_status(:bad_request)
            |> json(%{errors: format_changeset_errors(changeset)})
        end
    end
  end

  def get_user_by_id(conn, %{"id" => id}) do
    case Repo.get(User, id) do
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

    case Repo.get_by(User, username: username, email: email) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "User not found"})

      user ->
        json(conn, user_to_json(user))
    end
  end

  def put_user_by_id(conn, %{"id" => id} = params) do
    user_params = Map.get(params, "user", %{})

    case Repo.get(User, id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "User not found"})

      user ->
        changeset = User.changeset(user, user_params)

        case Repo.update(changeset) do
          {:ok, updated_user} ->
            conn
            |> put_status(:ok)  # 200 OK est plus approprié pour une mise à jour réussie
            |> json(user_to_json(updated_user))

          {:error, changeset} ->
            conn
            |> put_status(:bad_request)
            |> json(%{errors: format_changeset_errors(changeset)})
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
            |> put_status(:ok)  # ou :no_content si vous préférez
            |> json(%{message: "User deleted successfully"})

          {:error, changeset} ->
            conn
            |> put_status(:internal_server_error)
            |> json(%{error: "Failed to delete user", details: format_changeset_errors(changeset)})
        end
    end
  end


  defp user_to_json(user) do
    %{
      id: user.id,
      username: user.username,
      email: user.email
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