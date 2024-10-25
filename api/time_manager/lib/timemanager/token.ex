defmodule Timemanager.Token do
  use Joken.Config

  @impl true
  def token_config do
    default_claims(
      iss: "Timemanager",
      aud: "Timemanager users",
      default_exp: 60 * 60 * 24 * 30
    )
    |> add_claim("type", fn -> "access" end)
    |> add_claim("role", fn -> nil end)
    |> add_claim("sub", fn -> nil end)
    |> add_claim("teams", fn -> nil end)
    |> add_claim("xsrf", fn -> Ecto.UUID.generate() end)
  end

  @doc """
  Generates a token with custom claims.
  The user_id should be provided in the claims map as "sub".

  Example:
    Token.generate_token(%{
      "sub" => user.id,
      "role" => user.role.name,
      "xsrf" => xsrf_token
    })
  """
  def generate_token(claims) do
    # Validate required claims
    case validate_claims(claims) do
      :ok ->
        generate_and_sign(claims, get_signer())
      {:error, message} ->
        {:error, message}
    end
  end

  @doc """
  Verifies a token and returns the claims.
  """
  def verify_token(token) do
    case verify_and_validate(token, get_signer()) do
      {:ok, claims} ->
        if claims["sub"] && claims["role"] do
          {:ok, claims}
        else
          {:error, :invalid_claims}
        end
      error -> error
    end
  end

  defp get_signer do
    secret_key = Application.get_env(:timemanager, __MODULE__)[:secret_key]
    Joken.Signer.create("HS256", secret_key)
  end

  defp validate_claims(claims) do
    cond do
      !Map.has_key?(claims, "sub") ->
        {:error, "User ID is required"}
      !Map.has_key?(claims, "role") ->
        {:error, "Role is required"}
      true ->
        :ok
    end
  end

  @doc """
  Gets the user ID from claims.
  """
  def get_user_id(claims) when is_map(claims) do
    claims["sub"]
  end
  def get_user_id(_), do: nil

  @doc """
  Gets the user role from claims.
  """
  def get_user_role(claims) when is_map(claims) do
    claims["role"]
  end
  def get_user_role(_), do: nil

  def get_user_teams(claims) when is_map(claims) do
    claims["teams"]
  end
end