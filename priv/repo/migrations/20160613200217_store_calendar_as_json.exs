defmodule Billing.Repo.Migrations.StoreCalendarAsJson do
  use Ecto.Migration

  def change do
    # we'll want to ensure that when a user is deleted, all of the calendar
    # entries associated with them are as well. How to best approach this is
    # not clear yet, so for now, the :on_delete behavior will be to do
    # :nothing

    # replace with new table
    create table(:calendar_events) do
      add :user_id, references(:users, on_delete: :nothing)
      add :data, :map

      timestamps
    end

    create index(:calendar_events, [:user_id])
  end
end
