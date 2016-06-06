defmodule Billing.User do
  use Billing.Web, :model

  schema "users" do
    field :name, :string
    field :google_id, :string

    timestamps
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :google_id])
    |> validate_required([:name, :google_id])
  end

  #def get_by_google_id(google_id) do
  #  from u in Billing.User,
  #  where: u.google_id == google_id
  #end
end
