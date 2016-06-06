defmodule Billing.Auth do
  import Plug.Conn
  @behaviour Plug
  alias Billing.User

  @doc """
  Init takes a set of options and initializes it.

  The result returned by `init/1` is passed as second argument to `call/2`.

  Note that `init/1` may be called during compilation and as such it must not 
  return pids, ports or values that are not specific to the runtime.
  """
  def init(opts) do
    Keyword.fetch!(opts, :repo)
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
