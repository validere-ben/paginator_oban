defmodule Spike.Accounts.Account do
  use Spike.Schema

  alias Spike.Accounts.Role
  alias Spike.Accounts.User

  @required [
    :name
  ]

  schema "accounts" do
    field(:name, :string)

    has_many(:roles, Role)
    has_many(:users, User)

    timestamps()
  end

  def changeset(%__MODULE__{} = account, params) do
    account
    |> cast(params, @required)
    |> validate_required(@required)
  end
end
