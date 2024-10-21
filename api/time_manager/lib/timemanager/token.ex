defmodule Timemanager.Token do
  use Joken.Config

  @impl true
  def token_config do
    default_claims(
      iss: "Timemanager",
      aud: "Timemanager users",
      default_exp:  60 * 60 * 24 * 30
    )
    |> add_claim("type", fn -> "access" end)
    |> add_claim("role", fn -> nil end)
    |> add_claim("xsrf", fn -> Ecto.UUID.generate() end)
  end

  def generate_token(claims) do
    generate_and_sign(claims, get_signer())
  end

  def verify_token(token) do
    verify_and_validate(token, get_signer())
  end

  defp get_signer do
    secret_key = Application.get_env(:timemanager, __MODULE__)[:secret_key]
    Joken.Signer.create("HS256", secret_key)
  end
end