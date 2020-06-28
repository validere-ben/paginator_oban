defmodule SpikeWeb.PageController do
  use SpikeWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
