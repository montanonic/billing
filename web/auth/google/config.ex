defmodule Billing.GoogleAuth.Config do
  @doc """
  This sets up the core URL routes routes we will be using to authorize through
  Google OAuth2.
  """
  @config_routes [
    authorize_url: "https://accounts.google.com/o/oauth2/v2/auth",
    token_url: "https://www.googleapis.com/oauth2/v4/token",
    redirect_uri: "http://localhost:4000/auth/callback",
  ]

  @doc """
  Adds the BillingApp `client_id` and `client_secret` to the configuration. Keep
  in mind that we don't want the secrets to leak anywhere that is public or not
  encrypted, so ensure that this value is used securely.
  """
  def config do
    Application.get_env(:billing, Billing.GoogleAuth)
    |> Keyword.merge(@config_routes)
    |> Enum.into(Map.new)
  end
end
