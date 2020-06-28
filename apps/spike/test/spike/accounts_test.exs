defmodule Spike.AccountsTest do
  use Spike.DataCase, async: true

  alias Spike.Accounts
  alias Spike.Accounts.{Account, User, Role}
  alias Spike.Repo

  defp setup_data(context) do
    account = %Account{} |> Account.changeset(%{name: "bar"}) |> Repo.insert!()
    role = %Role{} |> Role.changeset(%{name: "foo", account_id: account.id}) |> Repo.insert!()
    Map.merge(context, %{account: account, role: role})
  end

  describe "invite_user/1" do
    setup [:setup_data]

    test "invites a user", %{account: account, role: role} do
      email = "foo@bar.com"
      role_id = role.id
      account_id = account.id
      opts = [email: email, role_id: role_id, account_id: account_id]

      assert {:ok, result} = Accounts.invite_user(opts)

      assert %User{email: ^email, role_id: ^role_id, account_id: ^account_id} = result
      assert_enqueued(worker: Accounts.Jobs.InviteEmail, queue: :default, args: %{email: email})
    end

    test "returns an error with invalid data", %{account: account, role: role} do
      opts = [email: nil, role_id: role.id, account_id: account.id]

      assert {:error, %Ecto.Changeset{}} = Accounts.invite_user(opts)

      refute_enqueued(worker: Accounts.Jobs.InviteEmail)
    end
  end
end
