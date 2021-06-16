defmodule NoughtsAndExs.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      NoughtsAndExsWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: NoughtsAndExs.PubSub},
      # Start the Endpoint (http/https)
      NoughtsAndExsWeb.Endpoint,
      # Start a worker by calling: NoughtsAndExs.Worker.start_link(arg)
      # {NoughtsAndExs.Worker, arg}
      {MyTracker, [name: MyTracker, pubsub_server: NoughtsAndExs.PubSub]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: NoughtsAndExs.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    NoughtsAndExsWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
