defmodule TimemanagerWeb.WorkingTimeController do
  use TimemanagerWeb, :controller
  alias Timemanager.Repo
  alias Timemanager.WorkingTime
  alias Timemanager.User
  import Ecto.Query

  def index(conn, %{"userID" => user_id} = params) do
    with {:ok, parsed_user_id} <- parse_integer(user_id),
         {:ok, query} <- build_query(parsed_user_id, params) do

      working_times = Repo.all(query)

      if Enum.empty?(working_times) do
        conn
        |> put_status(:not_found)
        |> json(%{error: "No working times found for this user"})
      else
        json(conn, Enum.map(working_times, &working_time_to_map/1))
      end
    else
      {:error, :invalid_integer} ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "Invalid user ID format"})

      {:error, :invalid_date, date_type} ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "Invalid #{date_type} date format. Expected ISO8601 format (e.g., 2024-10-15T15:00:00Z)"})
    end
  end

  def show(conn, %{"userID" => user_id, "id" => id}) do
    case Repo.get(WorkingTime, id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Working time not found"})

      working_time ->
        if working_time.user == String.to_integer(user_id) do
          json(conn, working_time_to_map(working_time))
        else
          conn
          |> put_status(:not_found)
          |> json(%{error: "Working time not found for this user"})
        end
    end
  end

  def create(conn, %{"userID" => user_id, "start" => start, "end" => end_time}) do
    case Repo.get(User, user_id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "User not found"})

      _ ->
        case validate_dates(start, end_time) do
          :ok ->
            working_time_params = %{
              user: String.to_integer(user_id),
              start: start,
              end: end_time
            }

            changeset = WorkingTime.changeset(%WorkingTime{}, working_time_params)

            case Repo.insert(changeset) do
              {:ok, working_time} ->
                conn
                |> put_status(:created)
                |> json(working_time_to_map(working_time))

              {:error, changeset} ->
                conn
                |> put_status(:unprocessable_entity)
                |> json(%{errors: changeset.errors})
            end

          {:error, message} ->
            conn
            |> put_status(:unprocessable_entity)
            |> json(%{errors: %{date: [message]}})
        end
    end
  end

  def update(conn, %{"id" => id} = params) do
    case Repo.get(WorkingTime, id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Working time not found"})

      working_time ->
        case validate_dates(params["start"], params["end"]) do
          :ok ->
            changeset = WorkingTime.changeset(working_time, params)

            case Repo.update(changeset) do
              {:ok, updated_working_time} ->
                conn
                |> put_status(:ok)
                |> json(working_time_to_map(updated_working_time))

              {:error, changeset} ->
                conn
                |> put_status(:unprocessable_entity)
                |> json(%{errors: changeset.errors})
            end

          {:error, message} ->
            conn
            |> put_status(:unprocessable_entity)
            |> json(%{errors: %{date: [message]}})
        end
    end
  end


  def delete(conn, %{"id" => id}) do
    case Repo.get(WorkingTime, id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Working time not found"})

      working_time ->
        case Repo.delete(working_time) do
          {:ok, _deleted_working_time} ->
            send_resp(conn, :no_content, "")

          {:error, changeset} ->
            conn
            |> put_status(:unprocessable_entity)
            |> json(%{errors: changeset.errors})
        end
    end
  end

  # Private functions

  defp parse_integer(value) when is_binary(value) do
    case Integer.parse(value) do
      {int, ""} -> {:ok, int}
      _ -> {:error, :invalid_integer}
    end
  end

  defp build_query(user_id, params) do
    base_query = from(w in WorkingTime, where: w.user == ^user_id)

    with {:ok, query} <- add_start_date(base_query, params),
         {:ok, query} <- add_end_date(query, params) do
      {:ok, query}
    end
  end

  defp add_start_date(query, %{"start" => start}) when is_binary(start) do
    case DateTime.from_iso8601(start) do
      {:ok, start_date, _} ->
        {:ok, from(w in query, where: w.start >= ^start_date)}
      _ ->
        {:error, :invalid_date, "start"}
    end
  end
  defp add_start_date(query, _), do: {:ok, query}

  defp add_end_date(query, %{"end" => end_time}) when is_binary(end_time) do
    case DateTime.from_iso8601(end_time) do
      {:ok, end_date, _} ->
        {:ok, from(w in query, where: w.end <= ^end_date)}
      _ ->
        {:error, :invalid_date, "end"}
    end
  end
  defp add_end_date(query, _), do: {:ok, query}

  defp working_time_to_map(working_time) do
    %{
      id: working_time.id,
      start: DateTime.to_iso8601(working_time.start),
      end: DateTime.to_iso8601(working_time.end),
      user: working_time.user
    }
  end

  defp working_time_to_map(working_time) do
    %{
      id: working_time.id,
      start: DateTime.to_iso8601(working_time.start),
      end: DateTime.to_iso8601(working_time.end),
      user: working_time.user
    }
  end

  defp validate_dates(start, end_time) do
      with {:ok, start_date, _} <- DateTime.from_iso8601(start),
           {:ok, end_date, _} <- DateTime.from_iso8601(end_time) do
        case DateTime.compare(start_date, end_date) do
          :lt ->
            time_diff = DateTime.diff(end_date, start_date, :second)
            max_seconds = 24 * 60 * 60  # 24 hours in seconds
            if time_diff <= max_seconds do
              :ok
            else
              {:error, "Time difference cannot be more than 24 hours"}
            end
          :eq ->
            {:error, "Start date and end date cannot be the same"}
          :gt ->
            {:error, "Start date must be before end date"}
        end
      else
        _ -> {:error, "Invalid date format"}
      end
    end
end