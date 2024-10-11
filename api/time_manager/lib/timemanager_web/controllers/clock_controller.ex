defmodule TimemanagerWeb.ClockController do
  use TimemanagerWeb, :controller
  alias Timemanager.{Repo, User, Clock}
  import Ecto.Query

  def index(conn, _params) do
    clocks = Repo.all(Clock)

    if Enum.empty?(clocks) do
      conn
      |> put_status(:not_found)
      |> json(%{error: "No clocks found"})
    else
      json(conn, Enum.map(clocks, &clock_to_json/1))
    end
  end

  def get_clock_by_user_id(conn, %{"userID" => id}) do
    case Repo.get(User, id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "User not found"})

      user ->
        clocks = get_user_clocks(user.id)
        case clocks do
          [] ->
            conn
            |> put_status(:not_found)
            |> json(%{error: "No clocks found for this user"})

          clocks ->
            conn
            |> put_status(:ok)
            |> json(%{clocks: Enum.map(clocks, &clock_to_json/1)})
        end
    end
  end

  defp get_user_clocks(user_id) do
    Clock
    |> where([c], c.user_id == ^user_id)
    |> order_by([c], desc: c.time)
    |> Repo.all()
  end

  def create(conn, %{"userID" => userID}) do
    case Integer.parse(userID) do
      {user_id, _} ->
        case Repo.get(User, user_id) do
          nil ->
            conn
            |> put_status(:not_found)
            |> json(%{error: "User not found"})

          user ->
            create_new_clock_entry(conn, user)
        end

      :error ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "Invalid user ID"})
    end
  end

  defp create_new_clock_entry(conn, user) do
    latest_clock = get_latest_clock(user.id)
    new_status = determine_new_status(latest_clock)

    clock_params = %{
      user_id: user.id,
      time: DateTime.utc_now(),
      status: new_status
    }
    changeset = Clock.changeset(%Clock{}, clock_params)

    case Repo.insert(changeset) do
      {:ok, clock} ->
        conn
        |> put_status(:created)
        |> json(%{
          message: if(new_status, do: "Clocked in", else: "Clocked out"),
          clock: clock_to_json(clock)
        })

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: "Error creating clock entry", details: changeset.errors})
    end
  end

  defp get_latest_clock(user_id) do
    Clock
    |> where([c], c.user_id == ^user_id)
    |> order_by([c], desc: c.time)
    |> limit(1)
    |> Repo.one()
  end

  defp determine_new_status(latest_clock) do
    case latest_clock do
      nil -> true  # If no previous entry, start with clock in (true)
      %Clock{status: last_status} -> !last_status  # Opposite of the last status
    end
  end

  defp clock_to_json(clock) do
    %{
      id: clock.id,
      time: clock.time,
      status: clock.status,
      user_id: clock.user_id
    }
  end
end