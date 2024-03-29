defmodule Billing.Web do
  @moduledoc """
  A module that keeps using definitions for controllers,
  views and so on.

  This can be used in your application as:

      use Billing.Web, :controller
      use Billing.Web, :view

  The definitions below will be executed for every view,
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below.
  """

  def resolver do
    quote do
      alias Billing.Repo
      alias Billing.Resolver.Helpers
      alias Ecto.Changeset
    end
  end

  def model do
    quote do
      use Ecto.Schema

      alias Billing.Repo
      import Ecto
      import Ecto.Changeset
      import Ecto.Query
    end
  end

  def controller do
    quote do
      use Phoenix.Controller

      alias Billing.Repo
      import Ecto
      import Ecto.Query

      import Billing.Router.Helpers
      import Billing.Gettext
    end
  end

  def view do
    quote do
      use Phoenix.View, root: "web/templates"

      # Import convenience functions from controllers
      import Phoenix.Controller, only: [get_csrf_token: 0, get_flash: 2, view_module: 1]

      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML

      import Billing.Router.Helpers
      import Billing.ErrorHelpers
      import Billing.Gettext
    end
  end

  def router do
    quote do
      use Phoenix.Router
    end
  end

  def channel do
    quote do
      use Phoenix.Channel

      alias Billing.Repo
      import Ecto
      import Ecto.Query
      import Billing.Gettext
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
