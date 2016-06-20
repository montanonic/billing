defmodule Billing.Repo.Migrations.DropGoogleEmailAsUniqueIndex do
  use Ecto.Migration

  @moduledoc """
  Google OAuth2 confirms that the email field in the google id_token may not
  always be unique.
  """

  def change do
    drop index(:users, [:google_email])
  end
end
