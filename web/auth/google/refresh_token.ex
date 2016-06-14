defmodule Billing.GoogleAuth.RefreshToken do
  @moduledoc """
  Using a Refresh Token:
  https://developers.google.com/identity/protocols/OAuth2WebServer#offline
  """

  import Billing.GoogleAuth.Config, only: [config: 0]

  @token_url config.token_url
  # The following fields are generated in `config/google_auth_secret.exs`
  @client_id config.client_id
  @client_secret config.client_secret


  @doc """
  Exchanges a refresh token for an access token.
  """
  @token_headers %{
    "Host" => "www.googleapis.com",
    "Content-Type" => "application/x-www-form-urlencoded",
    }
  def get_access_token!(refresh_token) do
    parameters =
      %{"refresh_token" => refresh_token,
        "client_id" => @client_id,
        "client_secret" => @client_secret,
        "grant_type" => "refresh_token",
      }

    %{"access_token" => access_token, "token_type" => "Bearer"} =
      HTTPoison.post!(@token_url, "", @token_headers, params: parameters)
      |> (fn response -> response.body end).()
      |> Poison.decode!

    access_token
  end

  @doc """
  Revokes the consent a user granted to us, disabling us from using whichever
  APIs our token/s granted access to. Takes an access token or refresh token,
  disabling the refresh token in either case.

  This is useful only in response to a user requesting that we do this, and
  depending on what rights a user has/does not have when their subscription
  expires, we may want to revoke a token then as well.
  """
  def revoke_token!(token) do
    revoke_url = "https://accounts.google.com/o/oauth2/revoke?token=#{token}"
    HTTPoison.get!(revoke_url)
  end

  @doc """
  Replaces a user's refresh token with a new one.
  """
  def put_refresh_token!(user, refresh_token) do
    Billing.Repo.update!(user, refresh_token: refresh_token)
  end
end
