defmodule Billing.CalendarEvent do
  use Billing.Web, :model

  @moduledoc """
  See `old-models` in the `old-docs` folder to see a description of each field.
  But, more straightforwardly, these all correspond to the Events entity within
  the Google Calendar API, and is fully documented there.

  We rely upon only a subset of the total existing fields within the Events
  entity, exluding anything that cannot be used by our application in any
  meaningful way. Note however that it's hard to know this for sure, so there
  are some fields below that are unlikely to ever be important, and in contrast
  we may want to incorporate fields that are not currently represented below but
  could improve/extend the app.
  """

  schema "calendar_events" do
    field :kind, :string
    field :etag, :string
    field :ident, :string
    field :html_link, :string
    field :created, Ecto.DateTime
    field :updated, Ecto.DateTime
    field :summary, :string
    field :description, :string
    field :location, :string
    field :color_id, :string
    field :start_date, Ecto.Date
    field :start_date_time, Ecto.DateTime
    field :start_date_timezone, :string
    field :end_date, Ecto.Date
    field :end_datetime, Ecto.DateTime
    field :end_date_timezone, :string
    field :ical_UID, :string

    timestamps
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:kind, :etag, :ident, :html_link, :created, :updated,
      :summary, :description, :location, :color_id, :start_date,
      :start_date_time, :start_date_timezone, :end_date, :end_datetime,
      :end_date_timezone, :ical_UID])
    # the following fields are just a guess at what we'll want to require.
    # Google Calendar uses a slightly weird and variable scheme for storing
    # start and end times, so some of these fields will actually reliably not
    # be present, but we can't know that in advance, so I figure we'll just
    # set the values of whatever isn't included to `nil` when creating
    # changesets in the meantime, assuming that this works.
    |> validate_required([:ident, :html_link, :summary, :description,
      :start_date, :start_date_time, :start_date_timezone, :end_date,
      :end_datetime, :end_date_timezone])
  end
end
