defmodule Spike.Accounts do
  alias Spike.Accounts.Jobs.InviteEmail
  alias Spike.Accounts.User
  alias Spike.Repo

  def invite_user(opts) when is_list(opts) do
    opts |> Map.new() |> invite_user()
  end

  def invite_user(opts) when is_map(opts) do
    Repo.transaction(fn ->
      with {:ok, user} <- %User{} |> User.changeset(opts) |> Repo.insert(),
           {:ok, job} <-  %{email: user.email} |> InviteEmail.new() |> Oban.insert() do
        IO.inspect(job, label: "#{user.email} invite email job")
        user
      else
        {:error, changeset} -> Repo.rollback(changeset)
      end
    end)
  end
end
