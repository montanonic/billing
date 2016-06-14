defmodule Billing.Repo.Migrations.AddSyncTokensFieldToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      # store `:sync_tokens` in the form of
      # %{"google_api_response_resource_name" => sync_token}
      # example: %{"calendar_events_list => sync_token}
      add :sync_tokens, :map
    end
  end
end
