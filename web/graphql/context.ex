defmodule Billing.GraphQL.Context do
  @moduledoc """
  See http://absinthe-graphql.org/guides/context/

  Run this after our authorization Plug. Currently supports passing in the
  current user into the Absinthe context. This allows us to ensure that they
  only access resources that they own (or nothing at all if they aren't logged
  in).
  """
  import Plug.Conn
  @behaviour Plug

  def init(opts), do: opts

  @doc """
  See `Billing.AuthController` and `Billing.Auth` for our Auth procedure.

  If we need to pass any additional conn-based information into Absinthe, this
  is the place to add it. Currently, the only field placed in `context` is
  `current_user`.
  """
  def call(conn, _) do
    context =
      %{current_user: conn.assigns[:current_user],
      # add any additional fields here
      }

    conn
    |> put_private(:absinthe, %{context: context)
  end

end
