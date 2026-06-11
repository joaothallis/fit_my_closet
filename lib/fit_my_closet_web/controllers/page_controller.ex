defmodule FitMyClosetWeb.PageController do
  use FitMyClosetWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
