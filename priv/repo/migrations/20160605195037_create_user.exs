defmodule Billing.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :name, :string
      add :google_id, :string

      timestamps
    end

  end
end
