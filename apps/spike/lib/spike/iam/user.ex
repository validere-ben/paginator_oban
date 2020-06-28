defmodule Spike.IAM.User do
  use Spike.Schema

  alias Spike.IAM.Account
  alias Spike.IAM.Role

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
