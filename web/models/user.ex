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
      ~w|identity refresh_token name google_email sync_tokens|a)
  end

  def create_new_user(params) do
    changeset(new, Map.merge(%{sync_tokens: %{}}, params))
    |> Repo.insert
  end

  @doc """
  Takes a Billing.User and a sync token in a map with a key using the name of
  the resource you're storing the token for, such as `"google_calendar_event"`.
  """
  def put_sync_token(user, next_sync_token) do
    updated_sync_tokens =
      # merge the new sync token into the user's sync_tokens map.
      user.sync_tokens |> Map.merge(next_sync_token)
    changeset(user, %{sync_tokens: updated_sync_tokens})
    |> Repo.update
  end

  # Sketch for how we'll delete a User.
  # We must be sure to revoke their refresh token, as if they ever sign up again
  # without having that, the server will crash, because google will not give us
  # a new token automatically unless consent has been revoked, or we forceably
  # ask for it. Long story short: just revoke the token, because obviously they
  # don't have access if we delete them.
  @unimplemented """
  def delete_user do
    Billing.GoogleAuth.RefreshToken.revoke_token!
  end
  """
end
