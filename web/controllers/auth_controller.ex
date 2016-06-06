defmodule Billing.AuthController do
  use Billing.Web, :controller
  alias Billing.GoogleAuth

  # See https://developers.google.com/+/web/api/rest/oauth#authorization-scopes
  # for information on scopes.

  def index(conn, _params) do
    redirect conn,
      external: GoogleAuth.authorization_url!(scope: "profile")
  end

  @doc """
  Logs the user out by dropping their session.
  """
  def delete(conn, _params) do
    conn
    |> configure_session(drop: true)
    |> send_resp(:ok, "logged out")
  end

  @doc """

  This is the the callback URL that the OAuth2 provider will redirect the user
  back to with a `code` that will be used to request an access token. The access
  token will then be used to access protected resources on behalf of the user.

  """
  def callback(conn, %{"code" => code}) do
    # Exchange an auth code for an access token
    token = GoogleAuth.get_token!(code: code)

    # Request the user's data with the access token
    user = {:ok, %{body: user}} = OAuth2.AccessToken.get(token,
      "https://www.googleapis.com/plus/v1/people/me")


    # Store the user in the session under `:current_user'.
    # In most cases, we'd probably just store the user's ID that can be used
    # to fetch from the database. In this case, since this example app has no
    # database, I'm just storing the user map.
    #
    # If you need to make additional resource requests, you may want to store
    # the access token as well.
    conn
    |> put_session(:current_user, user)
    |> put_session(:access_token, token.access_token)
    |> create_user(user)
    |> send_resp(:ok, "you have logged in")
  end

  defp get_user!(token) do
    {:ok, %{body: user}} = OAuth2.AccessToken.get(token,
      "https://www.googleapis.com/plus/v1/people/me")
    %{name: user["name"], avatar: user["picture"]}
  end


  # not sure what to do here. Was thinking we should check and see if user already exists in our db
  # based on google_id
  defp create_user(conn, %{"name" => name, "id" => id}) do
    user = Repo.one(User.get_by_google_id(id))

    user_params = %{
      user: name,
      id: id
    }

    changeset = User.changeset(%Billing.User{}, user_params)
    case Repo.insert(changeset) do
      {:ok, user} ->
        conn
    end
  end
end
