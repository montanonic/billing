defmodule Billing.CalendarEventResolver do
  use Billing.Web, :resolver
  alias Billing.CalendarEvent
  alias Billing.GoogleAPI.Calendar, as: CalendarAPI

  def search(args, _info) do

  end

  def search_and_fetch(args, %{context: context}) do
    case context.current_user do
      nil ->
        {:error, "User is not logged-in, and therefore cannot access calendars\
          ."}

      user ->
        store_new_events(args, user)
    end
  end

  defp store_new_events(args, user) do
    query_search_terms? =
      if search_terms = args.search_terms do
        # turn list into space-separated string, which is what CalAPI requires
        # for the `q` param.
        Enum.join(search_terms, " ")
        |> (& %{"q" => &1}).()
      end

    #  search_terms = args.search_terms

    # Use the `:starts_after` arg in the query to google API, but don't pull
    # events by search terms, instead, fetch all of them.

    # Map.merge(

    # Update the database with any new calendar entries.
    # We could return them here instead of refetching from the DB in the next
    # step, but (1) doing this is less complex and (2) fetching from the DB
    # ensures that the search strategies work the same for each event, since
    # searching CalAPI may be a different search-strategy than searching our DB,
    # even when using identical keywords.
    CalendarAPI.fetch_and_store_new_calendar_events(
      user,
      (args.calendar || "primary"), # calendar to search in
      (query_search_terms? || %{}) # the request params
    )

    # TODO: Search the DB and return the results of this query.
  end

end
