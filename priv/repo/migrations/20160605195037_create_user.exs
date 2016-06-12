defmodule Billing.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    create table(:users) do
      # the user's name tied to their google account
      add :name, :string
      # the email tied to their google account used to sign in
      add :google_email, :string
      # the address they prefer any emails to be sent to; if null, we default
      # to emailing to their google address.
      add :preferred_email, :string
      add :google_id, :string
      add :access_token, :string

      timestamps
    end
    create unique_index(:users, [:google_email])

  end
end
