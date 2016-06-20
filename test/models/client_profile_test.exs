defmodule Billing.ClientProfileTest do
  use Billing.ModelCase

  alias Billing.ClientProfile

  @valid_attrs %{all_day_hours: 42, bill_after: 42, bill_to: "some content", display_name: "some content", hourly_rate: 42, search_terms: %{}}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = ClientProfile.changeset(%ClientProfile{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = ClientProfile.changeset(%ClientProfile{}, @invalid_attrs)
    refute changeset.valid?
  end
end
