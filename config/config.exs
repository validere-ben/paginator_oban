# This file is responsible for configuring your umbrella
# and **all applications** and their dependencies with the
# help of Mix.Config.
#
# Note that all applications in your umbrella share the
# same configuration and dependencies, which is why they
# all use the same configuration file. If you want different
# configurations or dependencies per app, it is best to
# move said applications out of the umbrella.
use Mix.Config

# Configure Mix tasks and generators
config :spike,
  ecto_repos: [Spike.Repo],
  generators: [binary_id: true]

config :spike_web,
  ecto_repos: [Spike.Repo],
  generators: [context_app: :spike]

# Configures the endpoint
config :spike_web, SpikeWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "M5mBn7q61Qn7Unxml13NU/6+qqbh8aFsT/7ngoXh9hJnPfdjkpnr/1H0sA7sZuta",
  render_errors: [view: SpikeWeb.ErrorView, accepts: ~w(html json), layout: false],
  live_view: [signing_salt: "Wu+iPmeh"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
