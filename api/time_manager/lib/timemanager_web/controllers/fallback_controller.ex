defmodule TimemanagerWeb.FallbackController do
  use TimemanagerWeb, :controller

  def index(conn, _params) do
    json(conn, %{message: "Time Manager API Running"})
  end
end