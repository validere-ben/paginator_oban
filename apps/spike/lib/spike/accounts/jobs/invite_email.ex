defmodule Spike.Accounts.Jobs.InviteEmail do
  use Oban.Worker, queue: :default, max_attempts: 10

  @impl Oban.Worker
  def perform(%{email: email}, job) do
    # do stuff
    IO.inspect(email, label: inspect(job))
  end
end
