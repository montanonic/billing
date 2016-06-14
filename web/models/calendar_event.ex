defmodule Billing.CalendarEvent do
  use Billing.Web, :model

  schema "calendar_events" do
    belongs_to :user_id, Billing.User
    field :data, :map

    timestamps
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, ~w|user_id data|a)
    |> validate_required(~w|user_id data|a)
    |> forgeign_key_constraint(:user_id)
  end
end
