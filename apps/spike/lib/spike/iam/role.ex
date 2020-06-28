defmodule Spike.IAM.Role do
  use Spike.Schema

  alias Spike.IAM.Account
  alias Spike.IAM.User

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
