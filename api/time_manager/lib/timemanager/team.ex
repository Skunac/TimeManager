defmodule Timemanager.Team do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:id, :name, :inserted_at, :updated_at]}
  schema "teams" do
    field :name, :string
    many_to_many :users, Timemanager.User, join_through: "users_teams"

    timestamps()
  end

  def changeset(team, attrs) do
    team
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> validate_length(:name, min: 2, max: 100)
    |> unique_constraint(:name, name: "teams_name_index")
  end
end