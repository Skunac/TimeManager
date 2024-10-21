defmodule TimemanagerWeb.AuthController do
  use TimemanagerWeb, :controller
  alias Timemanager.User
  alias Timemanager.Token
  alias TimemanagerWeb.UserController
  require Logger

  def register(conn, user_params) do
    case UserController.create_user(conn, user_params) do
      {:ok, user} ->
        case Token.generate_token(%{"sub" => user.id}) do
          {:ok, token, _claims} ->
            conn
            |> put_status(:created)
            |> json(%{token: token, user: user})
          {:error, reason} ->
            conn
            |> put_status(:internal_server_error)
            |> json(%{error: "Failed to generate authentication token"})
        end

      {:error, :username_taken} ->
        conn
        |> put_status(:conflict)
        |> json(%{error: "Username already taken"})

      {:error, :email_taken} ->
        conn
        |> put_status(:conflict)
        |> json(%{error: "Email already in use"})

      {:error, errors} ->
        conn
        |> put_status(:bad_request)
        |> json(%{errors: errors})
    end
  end

  def login(conn, %{"email" => email, "password" => password}) do
    case User.authenticate(email, password) do
      {:ok, user} ->
        server_token = :crypto.strong_rand_bytes(32) |> Base.url_encode64(padding: false)
        client_token = :crypto.hash(:sha256, server_token) |> Base.url_encode64(padding: false)

        {:ok, jwt, claims} = Token.generate_token(%{
          "sub" => user.id,
          "role" => user.role.name,
          "xsrf" => server_token
        })

        conn = conn
               |> delete_resp_cookie("jwt")  # Delete the old cookie first
               |> put_resp_cookie("jwt", jwt, [
          http_only: true,
          secure: false,  # Set to true in production with HTTPS
          max_age: 3600,
          same_site: "Lax",
          path: "/"
        ])

        # Log the exact cookie being set
        cookie = conn.resp_cookies["jwt"]

        conn
        |> put_status(:ok)
        |> json(%{
          user: user_to_json(user),
          c_xsrf_token: client_token,
          expires_at: claims["exp"]
        })

      {:error, reason} ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Invalid credentials"})
    end
  end

  defp generate_c_xsrf_tokens do
    server_token = :crypto.strong_rand_bytes(32) |> Base.url_encode64()
    client_token = :crypto.hash(:sha256, server_token) |> Base.url_encode64()
    {server_token, client_token}
  end

  defp user_to_json(user) do
    %{
      id: user.id,
      email: user.email,
      username: user.username,
      role: if(Ecto.assoc_loaded?(user.role), do: user.role.name, else: "unknown")
    }
  end

  def logout(conn, _params) do
    conn
    |> delete_resp_cookie("jwt")
    |> put_status(:ok)
    |> json(%{message: "Logged out successfully"})
  end
end