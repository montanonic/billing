defmodule Billing.AuthController do
  use Billing.Web, :controller
  alias Billing.GoogleAuth

  # See https://developers.google.com/+/web/api/rest/oauth#authorization-scopes
  # for information on scopes.

  @doc """
  Authenticates the user, and if successfuly logs the user in if they already
  have an account, and otherwise creates a new account.
  """
  def login(conn, _params) do
    GoogleAuth.redirect_to_secure_authorization_url(conn,
      %{"scope" => "profile",
        "include_granted_scopes" => "true",
      }
    )
  end

  @doc """
  TODO: This route should only be authorized if the user is already logged-in.

  Grants us access to the user's calendar
  """
  def calendar(conn, _params) do
    GoogleAuth.redirect_to_secure_authorization_url(conn,
      %{"scope" => "calendar",
        "include_granted_scopes" => "true",
      }
    )
  end

  @doc """
  TODO: This route should only be authorized if the user is already logged-in.

  Grants us offline access to the user's authorized resources. We'll use this
  to query their Calendar for updates.
  """
  def offline(conn, _params) do
    GoogleAuth.redirect_to_secure_authorization_url(conn,
      %{"include_granted_scopes" => "true",
        "access_type" => "offline",
      }
    )
  end

  @doc """
  Logs the user out by dropping their session.
  """
  def logout(conn, _params) do
    conn
    |> configure_session(drop: true)
    |> send_resp(:ok, "logged out")
  end

  @doc """
  This is the the callback URL that the OAuth2 provider will redirect the user
  back to with a `code` that will be used to request an access token. The access
  token will then be used to access protected resources on behalf of the user.
  """
  def callback(conn, params) do
    result = GoogleAuth.callback_procedure(conn, params)

    # TODO: the result tells us if the user was an existing user, or is a new
    # one; we should probably use it in the future

    IO.inspect result

    conn
    |> send_resp(:ok, "you have logged in")
  end

    # Store the user in the session under `:current_user'.
    # In most cases, we'd probably just store the user's ID that can be used
    # to fetch from the database. In this case, since this example app has no
    # database, I'm just storing the user map.
    #
    # If you need to make additional resource requests, you may want to store
    # the access token as well.
    #conn
    #|> put_session(:current_user, user)
    # We need to also be sure to store the access token on the backend. Whether
    # or not it's valuable to store it in the session for quick access is
    # unclear. For now, I'll opt for simplicity and omit it from the session.
    # |> put_session(:access_token, token.access_token)
    # assuming that user, allows access to basic data.. user["name"]
    # if this is the case, I figured a private function to check/add a new user to our db
    #|> create_user(user)
    #|> send_resp(:ok, "you have logged in")
end
