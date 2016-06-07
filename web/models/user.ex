defmodule Billing.User do
  use Billing.Web, :model

  schema "users" do
    field :name, :string
    # the email tied to their google account used to sign in
    field :google_email, :string
    # the address they prefer any emails to be sent to; if null, we default
    # to emailing to their google address.
    field :preferred_email, :string
    field :google_id, :string
    field :access_token, :string

    timestamps
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params,
      ~w|name google_email preferred_email google_id access_token|a)
    |> validate_required(~w|name google_email google_id access_token|a)
  end

  #def get_by_google_id(google_id) do
  #  from u in Billing.User,
  #  where: u.google_id == google_id
  #end
end
