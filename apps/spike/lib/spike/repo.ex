defmodule Spike.Repo do
  use Ecto.Repo,
    otp_app: :spike,
    adapter: Ecto.Adapters.Postgres,
    migration_timestamps: [type: :utc_datetime_usec]

  use Scrivener

  def paginator(query, opts \\ [], repo_opts \\ []) do
    Paginator.paginate(query, opts, __MODULE__, repo_opts)
  end
end
