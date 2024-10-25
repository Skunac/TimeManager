defmodule Timemanager.User do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias Bcrypt
  alias Timemanager.{Repo, Team, Role}

  @valid_roles ["general_manager", "manager", "employee"]

  schema "users" do
    field :username, :string
    field :email, :string
    field :password, :string, virtual: true
    field :password_hash, :string
    belongs_to :role, Role
    many_to_many :teams, Team, join_through: "users_teams", on_replace: :delete

    timestamps(type: :utc_datetime)
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:username, :email, :password, :role_id])
    |> validate_required([:username, :email, :password])
    |> validate_length(:username, min: 3, max: 50)
    |> validate_length(:password, min: 6)
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must be a valid email address")
    |> unique_constraint(:username)
    |> unique_constraint(:email)
    |> check_role_id()
    |> put_password_hash()
  end

  @doc """
  Changeset for updating user information.
  Only updates provided fields while maintaining existing data.
  """
  def update_changeset(user, attrs) do
    user
    |> cast(attrs, [:username, :email, :password])
    |> validate_length(:username, min: 3, max: 50)
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must be a valid email address")
    |> unique_constraint(:username)
    |> unique_constraint(:email)
    |> maybe_put_password_hash()
  end

  @doc """
  Changeset for handling team associations.
  """
  def teams_changeset(user, attrs) do
    user
    |> cast(%{}, [])
    |> put_assoc(:teams, attrs.teams)
  end

  @doc """
  Changeset for updating user role.
  """
  def role_changeset(user, attrs) do
    user
    |> cast(attrs, [:role_id])
    |> validate_required([:role_id])
    |> check_role_id()
  end

  defp check_role_id(changeset) do
    case get_change(changeset, :role_id) do
      nil ->
        case Repo.get_by(Role, name: "employee") do
          nil -> add_error(changeset, :role_id, "Default role not found")
          role -> put_change(changeset, :role_id, role.id)
        end
      role_id ->
        case Repo.get(Role, role_id) do
          nil ->
            add_error(changeset, :role_id, "Role not found")
          role ->
            if role.name in @valid_roles do
              changeset
            else
              add_error(changeset, :role_id, "Invalid role")
            end
        end
    end
  end

  defp put_password_hash(%Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset) do
    change(changeset, password_hash: Bcrypt.hash_pwd_salt(password))
  end
  defp put_password_hash(changeset), do: changeset

  defp maybe_put_password_hash(changeset) do
    case get_change(changeset, :password) do
      nil -> changeset
      password ->
        if String.length(password) >= 6 do
          change(changeset, password_hash: Bcrypt.hash_pwd_salt(password))
        else
          add_error(changeset, :password, "should be at least 6 character(s)")
        end
    end
  end

  @doc """
  Authenticates a user by email and password.
  """
  def authenticate(email, password) do
    user = Repo.get_by(__MODULE__, email: email) |> Repo.preload([:role, :teams])

    cond do
      user && Bcrypt.verify_pass(password, user.password_hash) ->
        {:ok, user}
      user ->
        {:error, :invalid_password}
      true ->
        Bcrypt.no_user_verify()
        {:error, :not_found}
    end
  end

  @doc """
  Returns list of valid roles.
  """
  def valid_roles, do: @valid_roles
end