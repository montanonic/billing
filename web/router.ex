defmodule Billing.Router do
  use Billing.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :spa do # Single-page App
    plug :accepts, ["json"]
    plug :fetch_session
  end

  scope "/", Billing do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
  end

  scope "/auth", Billing do
    pipe_through :spa

    get "/", AuthController, :index
    get "/callback", AuthController, :callback
    delete "/logout", AuthController, :delete
  end

  # Other scopes may use custom stacks.
  # scope "/api", Billing do
  #   pipe_through :api
  # end
end
