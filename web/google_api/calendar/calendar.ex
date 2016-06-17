defmodule Billing.GoogleAPI.Calendar do

  @moduledoc """
  https://developers.google.com/google-apps/calendar/v3/reference/events/list#http-request

  TODO: Turn this into a GenServer.

  Because GenServers can hold onto state, we can properly chunk requests,
  calling a limited number of calendar events each time (say, 200 or so, instead
  of how ever many we get), and store them in phases on the backend, sending the
  next request after the previous is properly stored.

  Then we can set up a supervisor to watch over multiple GenServers to handle
  Calendar fetching in parallel, for multiple clients at once.
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
      %{"maxResults" => 2500, # we need to "paginate" in the future
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
  #defdelegate store_calendar_events(events_list), to: Billing.CalendarEvent

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
  def fetch_and_store_new_calendar_events(user, calendar_id \\ "primary",
    params \\ %{}
  ) do

    sync_token_name =
      "calendar_events_list"

    request_params =
      params
      |> Map.merge(%{"syncToken" => user.sync_tokens[sync_token_name]})

    # fetch an EventsList using the user's refresh token.
    # TODO: This does not handle requesting in chunks; such a behavior should be
    # added, ideally as a GenServer for calendar requesting, storing state.
    # This will only work for fetching up to 2500 calendar events in the
    # meantime, which feels wrong.
    events_list =
      Billing.GoogleAuth.RefreshToken.get_access_token!(user.refresh_token)
      |> get_calendar_events(calendar_id, request_params)

    # TODO: make the following two commands a transaction

    events_list
    |> Billing.CalendarEvent.store_calendar_events(user.id)

    # insert a new sync token if existing in the `events_list`
    if next_sync_token = events_list["nextSyncToken"] do
      Billing.User.put_sync_token(user, %{sync_token_name => next_sync_token})
    end

    :ok
  end

end
