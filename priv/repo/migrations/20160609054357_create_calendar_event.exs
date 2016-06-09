defmodule Billing.Repo.Migrations.CreateCalendarEvent do
  use Ecto.Migration

  def change do
    create table(:calendar_events) do
      # we'll want to ensure that when a user is deleted, all of the calendar
      # entries associated with them are as well. How to best approach this is
      # not clear yet, so for now, the :on_delete behavior will be to do
      # :nothing
      add :user_id, references(:users, on_delete: :nothing)
      add :kind, :string
      add :etag, :string
      add :ident, :string
      add :html_link, :string
      add :created, :datetime
      add :updated, :datetime
      add :summary, :string
      add :description, :string
      add :location, :string
      add :color_id, :string
      add :start_date, :date
      add :start_date_time, :datetime
      add :start_date_timezone, :string
      add :end_date, :date
      add :end_datetime, :datetime
      add :end_date_timezone, :string
      add :ical_UID, :string

      timestamps
    end
    create index(:calendar_events, [:user_id])

  end
end
