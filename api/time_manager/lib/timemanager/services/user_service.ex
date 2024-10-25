defmodule Timemanager.Accounts.UserService do
  alias Timemanager.{Repo, User, Team}
  import Ecto.Query

  def create_user(params) do
    teams = parse_teams(params["teams"])

    Repo.transaction(fn ->
      changeset = User.changeset(%User{}, params)

      with {:ok, user} <- Repo.insert(changeset),
           :ok <- associate_teams(user, teams) do
        user |> Repo.preload([:teams, :role])  # Return just the user, not a tuple
      else
        {:error, %Ecto.Changeset{} = changeset} ->
          Repo.rollback(handle_changeset_error(changeset))
        {:error, reason} ->
          Repo.rollback(reason)
      end
    end)
  end

  defp parse_teams(team_ids) when is_list(team_ids) do
    Repo.all(from t in Team, where: t.id in ^team_ids)
  end
  defp parse_teams(_), do: []

  defp associate_teams(user, teams) when is_list(teams) do
    now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)

    team_inserts = Enum.map(teams, fn team ->
      %{user_id: user.id, team_id: team.id, inserted_at: now, updated_at: now}
    end)

    case Repo.insert_all("users_teams", team_inserts) do
      {_, _} -> :ok
      _ -> {:error, :team_association_failed}
    end
  end
  defp associate_teams(_user, _teams), do: :ok

  defp handle_changeset_error(changeset) do
    case extract_error_type(changeset) do
      :email_taken -> :email_taken
      :username_taken -> :username_taken
      _ -> format_changeset_errors(changeset)
    end
  end

  defp extract_error_type(changeset) do
    cond do
      has_error?(changeset, :email, "has already been taken") -> :email_taken
      has_error?(changeset, :username, "has already been taken") -> :username_taken
      true -> :validation_error
    end
  end

  defp has_error?(changeset, field, message) do
    Enum.any?(changeset.errors, fn {key, {msg, _}} ->
      key == field and msg =~ message
    end)
  end

  defp format_changeset_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end
end