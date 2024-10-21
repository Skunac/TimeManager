defmodule Timemanager.User do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias Bcrypt
  alias Timemanager.Repo
  alias Timemanager.Team

  schema "users" do
    field :username, :string
    field :email, :string
    field :password, :string, virtual: true
    field :password_hash, :string
    belongs_to :role, Timemanager.Role
    many_to_many :teams, Timemanager.Team, join_through: "users_teams", on_replace: :delete

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:username, :email, :password, :role_id])
    |> validate_required([:username, :email, :password])
    |> unique_constraint(:username)
    |> unique_constraint(:email)
    |> unique_constraint([:username, :email])
    |> put_password_hash()
    |> validate_role()
  end

  defp put_password_hash(%Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset) do
    change(changeset, password_hash: Bcrypt.hash_pwd_salt(password))
  end
  defp put_password_hash(changeset), do: changeset

  defp validate_role(changeset) do
    if get_field(changeset, :role_id) do
      changeset
    else
      default_role = Repo.get_by(Timemanager.Role, name: "user")
      put_change(changeset, :role_id, default_role.id)
    end
  end

  def authenticate(email, password) do
    user = Repo.get_by(__MODULE__, email: email) |> Repo.preload(:role)
    case user do
      nil -> {:error, :not_found}
      _ ->
        if Bcrypt.verify_pass(password, user.password_hash) do
          {:ok, user}
        else
          {:error, :invalid_password}
        end
    end
  end
end