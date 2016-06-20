defmodule Billing.ClientProfile do
  use Billing.Web, :model

  @doc """
  `:search_terms` Search terms are what we use when using the Google API query
  parameter field, `q`, to filter out the calendar entries that the user wants
  to associate with this particular client. This field is of type `map`, because
  we will be storing search terms as a MapSet to ensure that there are no
  duplicate terms.

  `:hourly_rate`
  We store the user's hourly rate in cents to prevent any potential floating
  point arithmetic errors. It is highly unprofessional for any currency handling
  to round any values; all monetary calculations must be precise to the lowest
  denomination of the used currency.

  `:all_day_hours`
  All Day hours tells the application how many hours the user would bill the
  client for, for calendar events marked "all day", which blocks out an entire
  day and doesn't specify hours. defaults to 8 hours. The user can set their own
  default in their profile.

  `:bill_to` This field may be slightly premature, as it's not exactly clear how
  many pieces of information about the client we'll need to construct a proper
  invoice.
  """
  schema "client_profiles" do
    belongs_to :user, Billing.User

    field :display_name, :string
    field :search_terms, :map
    field :bill_after, :integer # in hours
    field :hourly_rate, :integer # in cents
    field :all_day_hours, :integer # defaults to 8 hours
    field :bill_to, :string

    timestamps
  end

  def new do
    %Billing.ClientProfile{all_day_hours: 8}
    |> changeset
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:display_name, :search_terms, :bill_after, :hourly_rate,
      :all_day_hours, :bill_to])
    |> validate_required([:display_name, :search_terms, :bill_after,
      :hourly_rate, :bill_to])
  end
end
