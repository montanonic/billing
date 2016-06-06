defmodule Billing.GoogleAuth do
  @moduledoc """
  An OAuth2 strategy for Google.
  """
  import OAuth2.Client
  import OAuth2.Strategy
  alias OAuth2.Strategy.AuthCode

  defp config do
    [strategy: Billing.GoogleAuth,
     site: "https://accounts.google.com",
     redirect_uri: "http://localhost:4000/auth/callback",
     authorize_url: "/o/oauth2/v2/auth",
     token_url: "/o/oauth2/v2/token",
    ]
  end

  # Public API

  @doc """
  A Google OAuth2 client entity.
  """
  def client do
    # we store the client id and secret in a file excluded from version control
    # for safety. The line below fetches those values, and subsequently we
    # merge them with the config defined above.
    Application.get_env(:billing, Billing.GoogleAuth)
    |> Keyword.merge(config)
    |> OAuth2.Client.new
  end

  @calendar "https://www.googleapis.com/auth/calendar.readonly"

  @doc """
  Generates the URL for the Google authorization page. For our app we use three
  scopes: Profile, Email, and Read-only Calendar, with offline access.
  """
  def authorization_url! do
    OAuth2.Client.authorize_url!(client, scope: "profile email #{@calendar}",
      access_type: "offline")
  end

  def get_token!(params \\ [], headers \\ []) do
    {:ok, res} = OAuth2.Client.get_token(client, params)
    res
  end

  # Strategy Callbacks


  def authorize_url(client, params \\ []) do
    client
    |> AuthCode.authorize_url(params)
  end

  def get_token(client, params, headers) do
    client
    |> put_header("Accept", "application/json")
    |> AuthCode.get_token(params, headers)
  end
end
