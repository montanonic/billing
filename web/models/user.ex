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
    # store `:sync_tokens` in the form of
    # %{"google_api_response_resource_name" => sync_token}
    # example: %{"calendar_events_list => sync_token}
    field :sync_tokens, :map

    timestamps
  end

  def new do
    %Billing.User{}
  end

  @doc """
  For account creation.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params,
      ~w|identity refresh_token name given_name family_name google_email
        preferred_email sync_tokens|a)
    |> validate_required(
      ~w|identity refresh_token name google_email|a)
  end

  def create_new_user(params) do
    changeset(new, params)
    |> Repo.insert
  end

  def put_sync_token(user,
    next_sync_token = %{google_api_resource => sync_token}
    ) do
    updated_sync_tokens =
      user.sync_tokens |> Map.merge(next_sync_token)
    changeset(user, %{sync_tokens: updated_sync_tokens)
    |> Repo.update
end
