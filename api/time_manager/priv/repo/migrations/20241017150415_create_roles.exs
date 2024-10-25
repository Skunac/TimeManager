defmodule Timemanager.Repo.Migrations.CreateRoles do
  use Ecto.Migration

  def change do
    create table(:roles) do
      add :name, :string, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:roles, [:name])

    # Make role_id non-nullable after setting default values
    alter table(:users) do
      add :role_id, references(:roles, on_delete: :restrict), null: false
    end

    # Add default roles
    execute """
    INSERT INTO roles (name, inserted_at, updated_at)
    VALUES
      ('general_manager', NOW(), NOW()),
      ('manager', NOW(), NOW()),
      ('employee', NOW(), NOW());
    """

    # Add admin user with hashed password
    execute """
    INSERT INTO users (username, email, password_hash, role_id, inserted_at, updated_at)
    VALUES (
      'admin',
      'admin@hotmail.com',
      '$2b$12$k8Y6Ot8cdFkWoWuuCRoMl.cvqbzS4YbLkKs0LjFNirzMD4Hc8uEvi',
      1,
      NOW(),
      NOW()
    );
    """
  end
end