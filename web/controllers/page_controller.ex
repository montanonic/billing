defmodule Billing.PageController do
  use Billing.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
