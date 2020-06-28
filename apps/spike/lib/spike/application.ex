defmodule Spike.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      Spike.Repo
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: Spike.Supervisor)
  end
end
