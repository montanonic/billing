defmodule Billing.Repo.Migrations.AddDefaultToCalendarEventTimestamps do
  use Ecto.Migration

  def change do
    alter table(:calendar_events) do
      remove :inserted_at
      remove :updated_at

      timestamps(default: "now()")
    end
  end
end
