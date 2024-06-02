defmodule Persistence.Repo.Migrations.CreateUsersAuthTables do
  use Ecto.Migration

  def change do
    execute "CREATE EXTENSION IF NOT EXISTS citext", ""

    create table(:users, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :first_name, :string, null: false
      add :last_name, :string, null: false
      add :cpf, :string, size: 11, null: false
      add :email, :citext, null: false
      add :hashed_password, :string, null: false
      add :confirmed_at, :naive_datetime
      timestamps(type: :utc_datetime)
    end

    create unique_index(:users, [:email], name: :users_email_index)
    create unique_index(:users, [:cpf], name: :users_cpf_index)

    create table(:users_tokens, primary_key: false) do
      add :id, :uuid, primary_key: true

      add :user_id, references(:users, on_delete: :delete_all, column: :id, type: :uuid),
        null: false

      add :token, :binary, null: false
      add :context, :string, null: false
      timestamps(updated_at: false)
    end

    create index(:users_tokens, [:user_id])
    create unique_index(:users_tokens, [:context, :token])
  end
end
