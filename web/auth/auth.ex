defmodule Billing.Auth do
  import Plug.Conn
  alias Billing.User

  def init(opts) do
    Keyword.fetch!(opts, repo)
  end

  def call(conn, repo) do
    google_user = get_session(conn, :current_user)
    user = google_user["id"] && user_by_google_id(repo, google_user["id"])
    assign(conn, :current_user, user)
  end

  defp user_by_google_id(repo, google_id) do
    query = User.get_by_google_id(google_id)
    repo.get!(query)
  end

end
