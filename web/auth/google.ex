defmodule GoogleAuth do

  @moduledoc """
  Everything in this module is derived from following the steps laid out here:
  https://developers.google.com/identity/protocols/OAuth2WebServer
  Some design ideas were taken from the OAuth2 Elixir library.
  """

  # Step 1: Set up basic configuration

  @doc """
  This sets up the core URL routes routes we will be using to authorize through
  Google OAuth2.
  """
  defp pre_config do
    [authorize_url: "https://accounts.google.com/o/oauth2/v2/auth",
     token_url: "https://accounts.google.com/o/oauth2/v4/token",
     redirect_uri: "http://localhost:4000/auth/callback",
    ]
  end

  @doc """
  Adds the BillingApp `client_id` and `client_secret` to the configuration. Keep
  in mind that we don't want the secrets to leak anywhere that is public or not
  encrypted, so ensure that this value is used securely.
  """
  defp config do
    Application.get_env(:billing, Billing.GoogleAuth)
    |> Keyword.merge(pre_config)
  end

  # Step 2: Redirect to Google's OAuth 2.0 server
  # TODO: Add a CSRF token in the `state` param to improve security.

  @doc """
  Generates a URL to Google's OAuth 2.0 server with parameters that flag for the
  appropriate authorization request. To use it, provide the scopes you'd like to
  authorize for, with whatever optional parameters you need (see rest of this
  documentation), and then redirect a user to the URL it generates.

  The full list of scopes are here:
  https://developers.google.com/identity/protocols/googlescopes
  Enter each scope exactly as is listed there (either as a word or full URL) as
  a string, and if requesting multiple scopes simply add a space between each
  one, but any other character will not work.

  This functions takes optional parameters (laid out in the protocol linked in
  the moduledoc) that set the request parameters in the generated URL; if a
  param defaults to a value, it will be listed to the right of the param name.

    `state`
    `access_type`, "offline"
    `prompt`
    `login_hint`
    `include_granted_scopes`, "false"


  Do not pass any param that is not listed above, as you risk invalidating the
  request.

  """
  def authorization_url(scope, params // []) do
    query_params =
      %{"response_type" => "code",
        "client_id" => config.client_id,
        "redirect_uri" => config.redirect_uri,
        "scope" => scope,
      } |> Keyword.merge(params)

    config.authorize_url <> "?" <> URI.encode_query(query_params)
  end
end
