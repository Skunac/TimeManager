defmodule TimemanagerWeb.AuthController do
  use TimemanagerWeb, :controller
  alias Timemanager.{User, Token}
  alias Timemanager.Accounts.UserService

  @cookie_options [
    http_only: true,
    secure: Mix.env() != :dev,
    max_age: 3600,
    same_site: "Lax",
    path: "/"
  ]

  def register(conn, user_params) do
    case UserService.create_user(user_params) do
      {:ok, user} ->
        handle_successful_auth(conn, user)

      {:error, :email_taken} ->
        conn
        |> put_status(:conflict)
        |> json(%{error: "Email already in use"})

      {:error, :username_taken} ->
        conn
        |> put_status(:conflict)
        |> json(%{error: "Username already taken"})

      {:error, :team_association_failed} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: "Failed to associate teams"})

      {:error, errors} when is_map(errors) ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: errors})

      {:error, _} ->
        conn
        |> put_status(:internal_server_error)
        |> json(%{error: "An unexpected error occurred"})
    end
  end

  def login(conn, %{"email" => email, "password" => password}) do
    case User.authenticate(email, password) do
      {:ok, user} ->
        handle_successful_auth(conn, user)

      {:error, _reason} ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Invalid credentials"})
    end
  end

  def logout(conn, _params) do
    conn
    |> delete_resp_cookie("jwt")
    |> put_status(:ok)
    |> json(%{message: "Logged out successfully"})
  end

  # Private functions

  defp handle_successful_auth(conn, user) do
    {server_token, client_token} = generate_tokens()

    case generate_jwt(user, server_token) do
      {:ok, jwt, claims} ->
        conn
        |> set_auth_cookie(jwt)
        |> put_status(:created)
        |> json(%{
          user: user_to_json(user),
          c_xsrf_token: client_token,
          expires_at: claims["exp"]
        })

      {:error, _reason} ->
        conn
        |> put_status(:internal_server_error)
        |> json(%{error: "Failed to generate authentication token"})
    end
  end

  defp generate_tokens do
    server_token = :crypto.strong_rand_bytes(32) |> Base.url_encode64(padding: false)
    client_token = :crypto.hash(:sha256, server_token) |> Base.url_encode64(padding: false)
    {server_token, client_token}
  end

  defp generate_jwt(user, server_token) do
    Token.generate_token(%{
      "sub" => user.id,
      "role" => user.role.name,
      "team" => user.teams,
      "xsrf" => server_token
    })
  end

  defp set_auth_cookie(conn, jwt) do
    conn
    |> delete_resp_cookie("jwt")
    |> put_resp_cookie("jwt", jwt, @cookie_options)
  end

  defp user_to_json(user) do
    %{
      id: user.id,
      email: user.email,
      username: user.username,
      role: get_role_name(user),
      teams: get_teams(user)
    }
  end

  defp get_role_name(user) do
    case user do
      %{role: %{name: name}} -> name
      _ -> "unknown"
    end
  end

  defp get_teams(user) do
    case user do
      %{teams: teams} when is_list(teams) ->
        Enum.map(teams, fn team -> %{id: team.id, name: team.name} end)
      _ ->
        []
    end
  end
end