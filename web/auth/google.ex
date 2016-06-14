defmodule Billing.GoogleAuth do
  @moduledoc """
  Everything in this module is derived from following the steps laid out here:
  https://developers.google.com/identity/protocols/OAuth2WebServer

  Though I orginally followed the steps above,
  https://developers.google.com/identity/protocols/OpenIDConnect
  has some more thorough explanations of setting up authentication, although
  it does not cover authorization to Google API services to the extent that
  the OAwuth2WebServer guide does.

  Reading a combination of both should be the most informative.

  Some design ideas were taken from the OAuth2 Elixir library.
  """

  @type access_token :: String.t


  ###
  # Step 1: Set up basic configuration
  ###

  import Billing.GoogleAuth.Config, only: [config: 0]

  @redirect_uri config.redirect_uri
  @authorize_url config.authorize_url
  @token_url config.token_url
  # The following fields are generated in `config/google_auth_secret.exs`
  @client_id config.client_id
  @client_secret config.client_secret

  ###
  # Step 2: Redirect to Google's OAuth 2.0 server
  ###

  @docp """
  ## Do not use this function directly.

  Please use and consult the documentation for
  `redirect_to_secure_authorization_url` instead, as it automatically generates
  and stores an anti-forgery token in the session, and passes it as a state
  parameter to the authorization url, ensuring that requests are securely made
  by the user and no-one else.

  ## Basic Usage

  Generates a URL to Google's OAuth 2.0 server with parameters that flag for the
  appropriate authorization request. To use it, you must provide a Map
  containing the `scope` parameter, with a string of space-delimited scopes
  you'd like to authorize for, along with any optional parameters. Once created,
  redirect a user to the generated URL, and the callback procedure will handle
  everything from there.

    Example:

        iex> scopes = "profile email " <>
        ...> "https://www.googleapis.com/auth/calendar.readonly"
        "profile email https://www.googleapis.com/auth/calendar.readonly"
        iex> authorization_url(%{"scope" => scopes})
        "https://accounts.google.com/o/oauth2/v2/auth?
          client_id=YOUR_CLIENT_ID.apps.googleusercontent.com&
          redirect_uri=http%3A%2F%2Flocalhost%3A4000%2Fauth%2Fcallback&
          response_type=code&
          scope=profile+email+https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fcalendar.readonly"

    (The result won't actually come formatted that way (it will come as a single
    string), and `YOUR_CLIENT_ID` will actually be a `client_id` value.)
  """
  defp authorization_url(params) do
    query_params =
      %{"response_type" => "code",
        "client_id" => @client_id,
        "redirect_uri" => @redirect_uri,
      } |> Map.merge(params)

    @authorize_url <> "?" <> URI.encode_query(query_params)
  end

  @doc """
  Sets the authorization parameters for everything that our app requires upon
  registration.
  """
  def registration_params do
    %{"scope" => "profile https://www.googleapis.com/auth/calendar.readonly",
      "access_type" => "offline",
    }
  end

  @doc """
  ## Basic Usage

  Requires the `scope` parameter. Redirects a user to a google url which
  allows for authentication and authorization. From there, the user will be
  redirected back to our `@redirect_uri`, at which point the
  `callback_procedure` will proceed.

  Consult the rest of this document along with the documentation linked in the
  moduledoc to better understand how to make your desired authorization
  request.

  This function fulfills steps 1 and 2 of the OpenIDConnect server flow:
  https://developers.google.com/identity/protocols/OpenIDConnect#createxsrftoken

  ## Scopes

  The full list of scopes are here:
  https://developers.google.com/identity/protocols/googlescopes

  Enter each scope exactly as is listed there (either as a word or full URL). A
  scope must be formatted as a string, and if requesting multiple scopes, each
  scope should be seperated by a single space within one string.

  ## Optional Parameters

  This functions takes optional string parameters which set the request
  parameters in the generated URL, all of which are explained here:
  https://developers.google.com/identity/protocols/OpenIDConnect#authenticationuriparameters
  I recommend to only set the following fields, if any, as several other fields
  (such as `state`) are automatically handled by the function.

    * `prompt`
    * `display`
    * `login_hint`
    * `access_type` - defaults to "online"; see **Offline Access**
    * `include_granted_scopes` - defaults to "false"; see **Incremental
        Authorization**


  ## Incremental Authorization

  The `"include_granted_scopes" => "true"` parameter setting allows for
  incremental authorization. By adding that key-value combination, the generated
  authorization url will remember all the scopes the user has previously
  authorized, and *only* ask the user for their authorization to the new scopes
  asked in this request. If granted, these new scopes and the old scopes will be
  combined into a new access token that covers all of them, allowing for users
  to grant us authorization to multiple services, without requiring that we
  store the particular access token associated with each of those different
  authorization request. Instead, we update the access token to one that covers
  all currently authorized scopes at once, which is a much more convenient way
  of doing things.

  ## Offline Access

  If you wish to be able to access any of the API resources while a user is
  logged-out, you'll need a refresh_token (which should be stored in the
  database in the user model). To get one, ensure that `%{"access_type" =>
  "offline"}` is set within the `params`. You will only get a refresh_token
  the first time they consent, so if the callback procedure does not store
  the refresh_token then, you'll have to force re-consent by setting `prompt`
  to `consent` in a future authorization request. Our current callback procedure
  properly handles `refresh_token` storage if it detects the field is present.
  """
  def redirect_to_secure_authorization_url(conn, %{"scope" => _} = params) do
    token =
      generate_anti_forgery_token()
    auth_url =
      %{"state" => token}
      |> Map.merge(params)
      |> authorization_url

    conn
    |> Plug.Conn.put_session(:anti_forgery_token, token)
    |> Phoenix.Controller.redirect(external: auth_url)
  end

  @docp """
  http://erlang.org/doc/man/crypto.html#strong_rand_bytes-1
  See https://developers.google.com/identity/protocols/OpenIDConnect#server-flow
  for the motivation.

  It may be best to only generate this token once per session. Currently, it
  is generated every time we go through the OAuth2 flow. At worst, this is
  solely a computational expense, and likely a minor one at that.

  32 bytes is a standard "secure" size.

  I use Base.encode64 because not all bytes from 1-255 are valid to send over
  the network, and Google's callback URL simply won't work if our token isn't
  encoded into some restricted format.

  The simpler explanation is that messaging protocols (which is what the web is)
  break easily, and don't handle all types of input data, and Base.encode64
  produces a format that will work across almost all platforms, so when facing
  an issue, try encoding your data using something from the Base module as a
  potential first-step.
  """
  defp generate_anti_forgery_token do
    :crypto.strong_rand_bytes(32)
    |> Base.encode64
  end


  ###
  # Step 3: Handle the OAuth 2.0 server response
  ###

  @doc """

  This function fulfills steps 3 and 4 of OpenIDConnect's server flow:
  https://developers.google.com/identity/protocols/OpenIDConnect#confirmxsrftoken

  OAuth2 works by first authenticating a user and obtaining their consent
  (which is what the Google OAuth2 server did in step two), and sending
  the response back to the `redirect_uri` we specify in our `pre_config`.

  That response will be one of the following two schemes (the `state` param
  will only be present if it was also present in the authorization url):

  * error=access_denied
  * code=ACCESS_TOKEN&state=ANTI_FORGERY_TOKEN

  And our callback procedure must handle both of those cases.

  ## Return value

  The return value of this function will be one of two atoms: `:existing_user`
  or `:new_user`, which is self-explanatory. In the latter case, the new user
  has just been created.

  NOTE:
    In the case of `error`, the user has chosen to *DENY* us consent to access
    those parts of their google account. We should absolutely respond to this
    by logging this event, and by sending the user to a page that explains the
    need for accessing those resources, and whatever else we'd like to say if
    they deny us consent.

  """
  @callback_headers %{
    "Host" => "www.googleapis.com",
    "Content-Type" => "application/x-www-form-urlencoded",
    }
  @spec callback_procedure!(String.t) ::
    {:existing_user | :current_user, Billing.User.t, access_token} |
    {:error, String.t}
  def callback_procedure(conn, %{"code" => code, "state" => state}) do
    case Plug.Conn.get_session(conn, :anti_forgery_token) do
      ^state ->
        get_authorization_response!(code)

      _ ->
        {:error, "state parameter was not equal to the anti_forgery_token " <>
          "stored in the session"}
    end
  end

  # TODO: As stated in the doc above, we ought to make a log when this occurs,
  # likely in our database itself, and then present the user with some UI to
  # explain why we need them to consent to those requirements. We could also
  # provide a link to a feedback area, if the user feels like they don't need
  # certain features of our application, for example, automated `bill_after`
  # reminders, and so in that case wouldn't need to grant us offline access.
  #
  # By only asking for consent when those features are absolutely required, we
  # may save ourselves lost users. On the flip side, it may feel more intrusive
  # to ask for email access, then for calendar access, then for offline access,
  # if we suspect our market will want all of those features basically no matter
  # what.
  def callback_procedure!(%{"error" => _}) do
    {:error, "access denied"}
  end

  @docp """
  This function fulfills steps 3 through 5 of OpenIDConnect's server flow:
  https://developers.google.com/identity/protocols/OpenIDConnect#server-flow

  Returns a tuple containing either the `:existing_user` atom if the user is
  already registered with our application, or `:new_user` otherwise, which we
  can handle differently to present first-time users a new page. The second
  tuple element is the user struct itself, which we can add to the session, and
  finally, the third element is an `access_token`.

  The current version of Google's OAuth2 API, as of July 9, 2016, also returns
  an `id_token` which contains basic user information inside of an encoded JWT.
  See http://stackoverflow.com/questions/8311836/how-to-identify-a-google-oauth2-user/13016081#13016081
  for more information on this, along with the `decode_id_token` function.
  """
  @spec get_authorization_response!(String.t) ::
    {:existing_user | :current_user, Billing.User.t, access_token}
  defp get_authorization_response!(code) do
    # params for making the callback request to exchange the authorization code
    # for an access token (and potentially a refresh token as well)
    parameters =
      %{"code" => code,
        "client_id" => @client_id,
        "client_secret" => @client_secret,
        "redirect_uri" => @redirect_uri,
        "grant_type" => "authorization_code",
      }

    callback_response =
      HTTPoison.post!(@token_url, "", @callback_headers, params: parameters)

    callback_response_json =
      Poison.decode!(callback_response.body)

    fetch_or_create_user!(callback_response_json)
  end


  @docp """
  Takes the decoded response to the google callback request, which must contain
  an `id_token`:
  (http://stackoverflow.com/questions/31099579/google-oauth-what-do-the-various-fields-in-id-token-stand-for#31099850
  The `id_token` contains identifying information about the authenticated user, which we
  can use to verify an existing user in our database, or to create a new account
  for them otherwise. This function will automatically do either, returning a
  response of

      `{:existing_user, the_existing_user}
  or
      `{:new_user, the_new_user}`

  This function makes certain critical assumptions about the data returned, such
  as an email being included and verified when creating a user. If these
  assumptions don't hold, it will crash. This is the appropriate response in
  such cases as we require cetain pieces of information to create or login a
  user; lacking that, there's not much else we can do except to debug and
  release a new version of the code.

  ## Security

  We do not verify the id token since it is given to us directly by google from
  the callback response, so there are no real concerns for security unless
  Google itself is compromised. We'll opt for the easy route for now, but
  later we may choose to be more cautious.

  TODO: (maybe) Use Google oauth certs to actually verify this token.
  """
  @spec fetch_or_create_user!(String.t) ::
    {:existing_user | :current_user, Billing.User.t, access_token}
  defp fetch_or_create_user!(response) do
    # See the SO link on an `id_token` for context on "sub".
    %{"sub" => unique_identifier} = identity =
      Joken.token(response["id_token"])
      |> Joken.peek

    # lookup the user by their identity to see if they are an existing user, or
    # a new user
    case Billing.Repo.get_by(Billing.User, identity: unique_identifier) do
      nil ->
        # create a new account
        {:ok, new_user} =
          Billing.User.create_new_user(
            %{identity: unique_identifier,
              refresh_token: response["refresh_token"],
              name: identity["name"],
              # we check to make sure their email is identified; an error will
              # be thrown otherwise
              google_email: identity["email_verified"] and identity["email"],
              given_name: identity["given_name"],
              family_name: identity["family_name"],
            }
          )
        {:new_user, new_user, response["access_token"]}

      user ->
        # see @explanation below
        if token = response["refresh_token"] do
          user
          |> Billing.GoogleAuth.RefreshToken.put_refresh_token!(token)
        end

        {:existing_user, user, response["access_token"]}
    end
  end
  @explanation """
  The `if` case above will only trigger if an existing user has revoked their
  refresh token at some point, as by logging in (which requires consent for
  offline access) a refresh token will be returned by the response.

  If a user has removed our app permissions, or we have revoked their tokens (on
  behalf of the user or otherwise), we must ensure that the user's session is
  terminated and that they must log-in again, forcing them to either reconsent
  to our authorization requests, or cease to use our services.
  """
end
