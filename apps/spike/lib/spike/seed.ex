defmodule Mix.Tasks.Spike.Seed do
  use Mix.Task

  alias Spike.Accounts.Account
  alias Spike.Accounts.Role
  alias Spike.Accounts.User
  alias Spike.Repo

  def run(_term) do
    Application.ensure_all_started(:spike)

    Repo.transaction(fn ->
      accounts()
      |> roles()
      |> users()
    end)
  end

  defp accounts do
    Enum.map(1..10, fn n ->
      %Account{name: "Account - #{n}"} |> Repo.insert!()
    end)
  end

  defp roles(accounts) do
    Enum.flat_map(accounts, fn account ->
      Enum.map(["Owner", "Admin", "Member"], fn name ->
        %Role{name: name, account_id: account.id} |> Repo.insert!()
      end)
    end)
  end

  defp users(roles) do
    Enum.flat_map(roles, fn role ->
      Enum.map(1..2, fn n ->
        %User{
          email: "#{role.name}-#{n}@#{random_string()}.com",
          role_id: role.id,
          account_id: role.account_id
        }
        |> Repo.insert!()
      end)
    end)
  end

  defp random_string do
    10 |> :crypto.strong_rand_bytes() |> Base.encode16()
  end
end
