defmodule Billing.GoogleAPI.Calendar do

  @moduledoc """
  https://developers.google.com/google-apps/calendar/v3/reference/events/list#http-request
  """

  @doc """
  If successful, returns an `events_list` response in parsed json format.

  Defaults the following request parameters as follows:

      `"maxResults" => 2500` # the maximum allowed
      `"singleEvents" => true`
  """
  def get_calendar_events(access_token, calendar_id \\ "primary",
  params \\ %{}) do
    request_headers =
      [ {"Authorization", "Bearer #{access_token}"} ]
    params =
      %{"maxResults" => 2500,
        "singleEvents" => true,
      } |> Map.merge(params)
    url =
      "https://www.googleapis.com/calendar/v3/calendars/#{calendar_id}/events"

    HTTPoison.get!(url, request_headers, params: params)
    |> (&(&1.body)).()
    |> Poison.decode!
  end

  @doc """
  When chained after `get_calendar_events`, will store the events on the
  backend,
  """
  def store_calendar_events(events_list) do

  end

  @doc """

  Takes a Billing.User, a calendar_id (defaults to their primary calendar), and
  fetches+stores all calendar events (from that calendar) resulting from the
  query. You may provide request parameters to alter the response. See the
  moduledocs.

  Automatically retrieves and uses any existing sync_token when making a
  request, and puts the resulting sync_token back into the user data. This
  ensures that we only fetch each event exactly once, unless changes are made to
  it.
  """
  def store_user_calendar_events(user, calendar_id \\ "primary",
    params \\ %{}
    ) do

    sync_token_name =
      "calendar_events_list"

    request_params =
      %{"syncToken" => user["sync_tokens"][sync_token_name],
      }

    events_list =
      Billing.GoogleAuth.RefreshToken.get_access_token!(user.refresh_token)
      |> get_calendar_events(calendar_id, request_params)


    # use Ecto.Multi for the following two commands.

    events_list
    |> store_calendar_events

    if next_sync_token = events_list["nextSyncToken"] do
      Billing.User.put_sync_token(user, %{sync_token_name => next_sync_token})
    end

    :ok
  end

end
