defmodule Billing.Auth do
  import Plug.Conn
  @behaviour Plug
  alias Billing.User

  ###
  # CALLBACKS
  ###

  @doc """
  Init takes a set of options and initializes it.

  The result returned by `init/1` is passed as second argument to `call/2`.

  Note that `init/1` may be called during compilation and as such it must not
  return pids, ports or values that are not specific to the runtime.
  """
  def init(opts) do
    Keyword.fetch!(opts, :repo)
  end

  @doc """
  If the person using our website is not logged-in, their `:current_user` field
  in `conn.assigns` will be `nil`.
  """
  def call(conn, repo) do
    user_id = get_session(conn, :user_id)
    user = user_id && repo.get(Billing.User, user_id)
    assign(conn, :current_user, user)
  end
end
