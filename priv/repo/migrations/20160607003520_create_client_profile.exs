defmodule Billing.Repo.Migrations.CreateClientProfile do
  use Ecto.Migration

  @moduledoc """
  YOU WILL NEED POSTGRES v9.4 OR HIGHER FOR THE `:map` TYPE TO WORK.

  I used this guide to install:
  https://www.howtoforge.com/tutorial/how-to-install-postgresql-95-on-ubuntu-12_04-15_10/

  And then added a local role following the suggestions here:
  http://stackoverflow.com/questions/11919391/postgresql-error-fatal-role-username-does-not-exist

  Commands were:
    sudo -u postgres -i
    psql
    CREATE ROLE nicholas superuser createdb login;
    CREATE DATABASE nicholas with owner nicholas;
    \password   ***SET THE PASSWORD TO   postgres   FOLLOWING THE PROMPT***
    \q
    ctrl-d

  PSQL v9.4 added the `jsonb` data type, which is what `:map` corresponds to.
  """

  @doc """
  See the ClientProfile model documentation for further information.
  """
  def change do
    create table(:client_profiles) do
      add :display_name, :string
      add :search_terms, :map
      add :bill_after, :integer
      add :hourly_rate, :integer
      add :all_day_hours, :integer
      add :bill_to, :string
      add :user_id, references(:users, on_delete: :nothing)

      timestamps
    end
    create index(:client_profiles, [:user_id])

  end
end
