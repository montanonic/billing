defmodule Billing.Schema do

  use Absinthe.Schema

  import_types Billing.Schema.Types

  query do

    @desc "Search and retrieve CalendarEvents stored in our database."
    field :calendar_events, list_of(:calendar_event) do
      # TODO: use custom scalar
      arg :starts_after, :string, description: "Only query events which start\
        after the given datetime."
      resolve &Billing.CalendarEventResolver.search/2
    end

  end

  mutation do

    @desc "Search and retrieve CalendarEvents stored in our database, along\
      with fetching new events which fit the search criteria from the user's\
      Calendar. This ensures that you'll always have access to the latest\
      events."
    field :calendar_events, list_of(:calendar_event) do
      @desc "Terms to filter the events by."
      arg :search_terms, list_of(:string)

      @desc "Which of the user's calendars to search in. Defaults to their\
        \"primary\" calendar."
      arg :calendar, :string

      @desc "Only query events which start after the given datetime."
      arg :starts_after, :datetime

      resolve &Billing.CalendarEventResolver.search_and_fetch/2
    end

  end

end
