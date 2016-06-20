defmodule Billing.CalendarEventTest do
  use Billing.ModelCase

  alias Billing.CalendarEvent

  @valid_attrs %{color_id: "some content", created: %{day: 17, hour: 14, min: 0, month: 4, sec: 0, year: 2010}, description: "some content", end_date: %{day: 17, month: 4, year: 2010}, end_date_timezone: "some content", end_datetime: %{day: 17, hour: 14, min: 0, month: 4, sec: 0, year: 2010}, etag: "some content", html_link: "some content", ical_UID: "some content", ident: "some content", kind: "some content", location: "some content", start_date: %{day: 17, month: 4, year: 2010}, start_date_time: %{day: 17, hour: 14, min: 0, month: 4, sec: 0, year: 2010}, start_date_timezone: "some content", summary: "some content", update: %{day: 17, hour: 14, min: 0, month: 4, sec: 0, year: 2010}}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = CalendarEvent.changeset(%CalendarEvent{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = CalendarEvent.changeset(%CalendarEvent{}, @invalid_attrs)
    refute changeset.valid?
  end
end
