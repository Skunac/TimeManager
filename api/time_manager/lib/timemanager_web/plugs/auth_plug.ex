defmodule TimemanagerWeb.AuthPlug do
  import Plug.Conn
  alias Timemanager.Token
  require Logger

  def init(opts), do: opts

  def call(conn, _opts) do
    case conn.cookies["jwt"] do
      nil ->
        unauthorized(conn, "Missing token")

      jwt ->
        case Token.verify_token(jwt) do
          {:ok, claims} ->
            case verify_xsrf(conn, claims) do
              true ->
                assign(conn, :current_user_id, claims["sub"])
              false ->
                forbidden(conn, "Invalid XSRF token")
            end

          {:error, :exp} ->
            unauthorized(conn, "Token expired", "TOKEN_EXPIRED")

          error ->
            unauthorized(conn, "Invalid token")
        end
    end
  end

  defp verify_xsrf(conn, claims) do
    server_token = claims["xsrf"]
    [client_token] = get_req_header(conn, "x-c-xsrf-token")

    expected_client = :crypto.hash(:sha256, server_token) |> Base.url_encode64(padding: false)

    result = Plug.Crypto.secure_compare(expected_client, client_token)
    result
  end

  defp unauthorized(conn, message, code \\ nil) do
    conn
    |> put_status(:unauthorized)
    |> Phoenix.Controller.json(%{error: message, code: code})
    |> halt()
  end

  defp forbidden(conn, message) do
    conn
    |> put_status(:forbidden)
    |> Phoenix.Controller.json(%{error: message})
    |> halt()
  end
end