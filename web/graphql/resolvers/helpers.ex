defmodule Billing.Resolver.Helpers do
  alias Ecto.Changeset

  @doc """
  Taken from https://hexdocs.pm/ecto/2.0.0-rc.5/Ecto.Changeset.html#traverse_errors/2.
  This function takes changeset errors and interpolates the values to properly
  render errors. For example:

  `"should be at least %{count} characters", [count: 3]`
  would become
  `"should be at least 3 characters"`
  """
  def render_changeset_errors(changeset) do
    Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(msg, "%{#{key}}", to_string(value))
      end)
    end)
  end

  @doc """
  Transforms the result from *most* Repo actions into a more readable format for
  GraphQL whenever the Repo action failed.

  For this function to work, the Repo action must return the following spec:

      `{:ok, result} | {:error, changeset}`
  """
  def prettify(repo_action_result) do
    case repo_action_result do
      {:ok, result} ->
        {:ok, result}
      {:error, changeset} ->
        {:error, render_changeset_errors(changeset)}
    end
  end
end
