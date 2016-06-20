defmodule Billing.AuthController do
  use Billing.Web, :controller
  alias Billing.GoogleAuth

  # See https://developers.google.com/+/web/api/rest/oauth#authorization-scopes
  # for information on scopes.

  @doc """
  Authenticates the user, and if successfuly logs the user in if they already
  have an account, and otherwise creates a new account.

  Requires consent for read-only access to a user's profile and calendar, along
  with consent for offline access to those resources.
  """
  def login(conn, _params) do
    if conn.assigns.current_user do
      conn
      |> send_resp(:ok, "already logged-in")

    else
      GoogleAuth.redirect_to_secure_authorization_url(conn,
        GoogleAuth.registration_params
      )
    end
  end

  @doc """
  Logs the user out by dropping their session.
  """
  def logout(conn, _params) do
    unless conn.assigns.current_user do
      conn
      |> send_resp(:ok, "already logged-out")

    else
      conn
      |> configure_session(drop: true)
      |> send_resp(:ok, "logged out")
    end
  end

  @doc """
  This is the the callback URL that the OAuth2 provider will redirect the user
  back to with a `code` that will be used to request an access token, along with
  profile information to login or register a user.

  If the callback procedure is successful, we store the user_id in the client's
  session, along with the access token.
  """
  def callback(conn, params) do
    {existing_user_or_new_user, user, access_token} =
      GoogleAuth.callback_procedure(conn, params)

    conn
    |> put_session(:user_id, user.id)
    |> put_session(:access_token, access_token)
    # include in our response information about if this is a first-time user
    # or a current user
    |> send_resp(:ok, Atom.to_string(existing_user_or_new_user))
  end
end
