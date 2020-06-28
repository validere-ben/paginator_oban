defmodule Spike.Accounts.User do
  use Spike.Schema

  alias Spike.Accounts.Account
  alias Spike.Accounts.Role

  @required [
    :email,
    :role_id,
    :account_id
  ]

  schema "users" do
    field(:email, :string)

    belongs_to(:role, Role)
    belongs_to(:account, Account)

    timestamps()
  end

  def changeset(%__MODULE__{} = account, params) do
    account
    |> cast(params, @required)
    |> validate_required(@required)
  end
end
