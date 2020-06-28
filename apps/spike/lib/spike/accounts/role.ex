defmodule Spike.Accounts.Role do
  use Spike.Schema

  alias Spike.Accounts.Account
  alias Spike.Accounts.User

  @required [
    :name,
    :account_id
  ]

  schema "roles" do
    field(:name, :string)

    belongs_to(:account, Account)

    has_many(:users, User)

    timestamps()
  end

  def changeset(%__MODULE__{} = account, params) do
    account
    |> cast(params, @required)
    |> validate_required(@required)
  end
end
