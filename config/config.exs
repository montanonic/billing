# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :billing,
  ecto_repos: [Billing.Repo]

# Configures the endpoint
config :billing, Billing.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "jERLoUq0o4gJaFcIOsbuYItotpzjKMe2Z+SKtJm8FUkqut3990iD/WBShmz8iFal",
  render_errors: [view: Billing.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Billing.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"

# Google API configuration variables
import_config "google_auth_vars.exs"
