defmodule Spike.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      Spike.Repo,
      {Oban, oban_config()}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: Spike.Supervisor)
  end

  defp oban_config do
    opts = Application.get_env(:spike, Oban)

    if Code.ensure_loaded?(IEx) and IEx.started?() do
      opts |> Keyword.put(:crontab, false) |> Keyword.put(:queues, false)
    else
      opts
    end
  end
end
