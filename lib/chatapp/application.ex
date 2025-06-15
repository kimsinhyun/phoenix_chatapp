defmodule Chatapp.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    # ETS 테이블 생성 (온라인 사용자 추적용)
    :ets.new(:online_users, [:set, :public, :named_table])

    children = [
      ChatappWeb.Telemetry,
      Chatapp.Repo,
      {DNSCluster, query: Application.get_env(:chatapp, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Chatapp.PubSub},
      # Start a worker by calling: Chatapp.Worker.start_link(arg)
      # {Chatapp.Worker, arg},
      # Start to serve requests, typically the last entry
      ChatappWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Chatapp.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ChatappWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
