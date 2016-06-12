defmodule Billing.User do
  use Billing.Web, :model

  schema "users" do
    field :identity, :string
    field :refresh_token, :string
    field :name, :string
    field :given_name, :string
    field :family_name, :string
    # the email tied to their google account used to sign in
    field :google_email, :string
    # the address they prefer any emails to be sent to; if null, we default
    # to emailing to their google address.
    field :preferred_email, :string

    timestamps
  end

  def new do
    %Billing.User{}
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params,
      ~w|identity refresh_token name given_name family_name google_email
        preferred_email|a)
    |> validate_required(
      ~w|identity name google_email|a)
  end

  def create_new_user(params) do
    changeset(new, params)
    |> Repo.insert
  end

  #def get_by_google_id(google_id) do
  #  from u in Billing.User,
  #  where: u.google_id == google_id
  #end
end
