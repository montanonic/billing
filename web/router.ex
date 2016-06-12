defmodule Billing.Router do
  use Billing.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Billing.Auth, repo: Billing.Repo
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :spa do # Single-page App
    plug :accepts, ["json"]
    plug :fetch_session
    plug Billing.Auth, repo: Billing.Repo
  end

  scope "/", Billing do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
  end

  scope "/auth", Billing do
    pipe_through :spa

    get "/login", AuthController, :login
    get "/callback", AuthController, :callback
    delete "/logout", AuthController, :logout
  end

  # Other scopes may use custom stacks.
  # scope "/api", Billing do
  #   pipe_through :api
  # end
end
