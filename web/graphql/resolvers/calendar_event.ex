defmodule Billing.CalendarEventResolver do
  use Billing.Web, :resolver
  alias Billing.CalendarEvent
  alias Billing.GoogleAPI.StoreCalendarEvents, as: CalendarAPI
  import Ecto.Query, only: [from: 2]

  def search(args, _info) do

  end

  def search_and_fetch(args, %{context: context}) do
    case context.current_user do
      nil ->
        {:error, "User is not logged-in, and therefore cannot access calendars\
          ."}

      user ->
        store_new_events(args, user)
        # then search events in the database
        # very rough implementation below
        #   def search_calendar_events(events_list, args) do
        #    from(Billing.CalendarEvent in query,
        #    where: fragment("?->>'startsAfter' == ?", args.

    end
  end

  @docp """
  Retrieves any new events from Google API and stores them in the database. Uses
  the arguments set in the graphql query to more selectively fetch events
  """
  defp store_new_events(args, user) do

    # https://developers.google.com/google-apps/calendar/v3/reference/events/list
    params =
      %{"timeMin" =>
          # if the `starts_after` arg isn't null, format it according to what
          # the CalendarAPI expects
          args.starts_after && Timex.format!(args.starts_after, "{ISOz}")
      }
      # remove any entries in the Map with nil values
      |> Enum.filter(fn {k,v} -> not is_nil(v) end)
      |> Map.new

    # Update the database with any new calendar entries.
    # We could return them here instead of refetching from the DB in the next
    # step, but (1) doing this is less complex and (2) fetching from the DB
    # ensures that the search strategies work the same for each event, since
    # searching CalAPI may be a different search-strategy than searching our DB,
    # even when using identical keywords.
    CalendarAPI.fetch_and_store_new_calendar_events(
      user,
      (args.calendar || "primary"), # calendar to search in
      params # the request params
    )
  end

end
