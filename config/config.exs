# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Configures the endpoint
config :noughts_and_exs, NoughtsAndExsWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "E5Ik2c3QaukJ+d2E8vioZHo5hefYwBE3JhUho4W40EQUcredqHYCMi2z7iiA6GWl",
  render_errors: [view: NoughtsAndExsWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: NoughtsAndExs.PubSub,
  live_view: [signing_salt: "LxmZ1eeB"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
