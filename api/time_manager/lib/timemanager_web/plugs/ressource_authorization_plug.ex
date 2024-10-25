defmodule TimemanagerWeb.AuthorizationPlug do
  import Plug.Conn
  import Phoenix.Controller
  import Ecto.Query
  alias Timemanager.{Repo, User}

  def init(opts) do
    %{
      user_id_param: Keyword.get(opts, :user_id_param, "id"),
      require_manager: Keyword.get(opts, :require_manager, true),
      allow_team_access: Keyword.get(opts, :allow_team_access, false)
    }
  end

  def call(conn, opts) do
    user_id_param = opts.user_id_param
    current_user_id = conn.assigns[:current_user_id]
    current_user_role = conn.assigns[:current_user_role]
    resource_user_id = get_resource_user_id(conn, user_id_param)
    require_manager = opts.require_manager
    allow_team_access = opts.allow_team_access

    cond do
      # Manager routes - require manager role
      require_manager ->
        if current_user_role in ["manager", "general_manager"] do
          conn
        else
          unauthorized_access(conn)
        end

      # Self access routes - only allow own resources
      !require_manager && !allow_team_access ->
        if to_string(current_user_id) == to_string(resource_user_id) do
          conn
        else
          unauthorized_access(conn)
        end

      # Team access routes - allow self access or manager access to team members
      !require_manager && allow_team_access ->
        cond do
          # Self access
          to_string(current_user_id) == to_string(resource_user_id) ->
            conn

          # Manager access to team members
          current_user_role in ["manager", "general_manager"] ->
            case check_team_access(current_user_id, resource_user_id) do
              true -> conn
              false -> unauthorized_access(conn)
            end

          true ->
            unauthorized_access(conn)
        end

      true ->
        unauthorized_access(conn)
    end
  end

  defp check_team_access(_manager_id, nil), do: true
  defp check_team_access(manager_id, user_id) do
    user_id = to_integer(user_id)
    query = from ut1 in "users_teams",
                 join: ut2 in "users_teams",
                 on: ut1.team_id == ut2.team_id,
                 where: ut1.user_id == ^manager_id and ut2.user_id == ^user_id,
                 select: count(ut1.team_id)

    Repo.one(query) > 0
  end

  defp get_resource_user_id(conn, param) do
    case conn.params do
      %{^param => id} -> id
      %{"userID" => id} -> id
      _ -> nil
    end
  end

  defp unauthorized_access(conn) do
    conn
    |> put_status(:forbidden)
    |> json(%{error: "You don't have permission to access this resource"})
    |> halt()
  end

  defp to_integer(value) when is_binary(value) do
    case Integer.parse(value) do
      {int, ""} -> int
      _ -> nil
    end
  end
  defp to_integer(value) when is_integer(value), do: value
  defp to_integer(_), do: nil
end