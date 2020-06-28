defmodule PageSpike.Repo.Migrations.AddTables do
  use Ecto.Migration

  def up do
    create(table(:accounts, primary_key: false)) do
      add(:id, :binary_id, primary_key: true)
      add(:name, :string, null: false)
      timestamps(type: :utc_datetime_usec)
    end

    create(unique_index(:accounts, :name))

    create(table(:roles, primary_key: false)) do
      add(:id, :binary_id, primary_key: true)
      add(:name, :string, null: false)
      add(:account_id, references(:accounts, type: :binary_id), null: false)
      timestamps(type: :utc_datetime_usec)
    end

    create(unique_index(:roles, [:name, :account_id]))

    create(table(:users, primary_key: false)) do
      add(:id, :binary_id, primary_key: true)
      add(:email, :string, null: false)
      add(:account_id, references(:accounts, type: :binary_id), null: false)
      add(:role_id, references(:roles, type: :binary_id), null: false)
      timestamps(type: :utc_datetime_usec)
    end

    create(unique_index(:users, :email))
  end

  def down do
    drop(table(:users))
    drop(table(:roles))
    drop(table(:accounts))
  end
end
