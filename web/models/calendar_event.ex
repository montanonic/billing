defmodule Billing.CalendarEvent do
  use Billing.Web, :model
#  @derive [Enumerable]

  schema "calendar_events" do
    belongs_to :user, Billing.User
    field :data, :map

    timestamps
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, ~w|user_id data|a)
    |> validate_required(~w|user_id data|a)
    |> foreign_key_constraint(:user_id)
  end

  def new do
    %Billing.CalendarEvent{}
  end

  def store_calendar_events(events_list, user_id) do
    # CalendarEvents are stored within the "items" field of the events_list
    # response according to the current Calendar API.
    calendar_events =
      events_list["items"]
      |> Enum.map(fn event ->
        changeset(new, %{user_id: user_id, data: event})
      end)

    # TODO: Use Repo.insert_all instead

    # Insert each event into the database. This is probably fairly innefficient.
    Enum.each(calendar_events,
      fn event -> Repo.insert(event)
    end)
    # But here's the (truncated) error we get if we try using
    # `Repo.insert_all(Billing.CalendarEvent, calendar_events)`:
    # `** (Protocol.UndefinedError) protocol Enumerable not implemented for
    # #Ecto.Changeset ...`
  end

end
