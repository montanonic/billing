defmodule Billing.Repo.Migrations.AlterUserForAuthCompatibility do
  use Ecto.Migration

  def change do
    alter table(:users) do
      # A unique identifier for an authenticated user. We use the Google
      # Identity Platform's "sub" value for this currently, but we can expand
      # this to work with more auethentication backends if needed.
      add :identity, :string
      add :refresh_token, :string

      # for parity with google's naming fields. There are 3, we already use
      # "name", so this is adding the other two, which as far as I can tell
      # correspond with first and last name.
      add :family_name, :string
      add :given_name, :string


      # we remove this in favor of the more generic "ident" field
      remove :google_id
      # access_tokens have time-limited-use, whereas refresh tokens can generate
      # new access_tokens whenever. Hence, we don't want to persist
      # access_tokens, but rather, the refresh_token.
      remove :access_token
    end
    # we will be querying by ident when logging in a user, hence we want to
    # index on it
    create unique_index(:users, [:identity])

  end
end
