defmodule Timemanager.Repo.Migrations.CreateWorkingTimes do
  use Ecto.Migration

  def change do
    create table(:working_times) do
      add :start, :utc_datetime, null: false
      add :end, :utc_datetime, null: false
      add :user, references(:users, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:working_times, [:user])
  end
end
