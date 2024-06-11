defmodule Persistence.Repo.Migrations.AddsFieldStore do
  use Ecto.Migration

  def change do
    alter table(:stores) do
      add :user_id, references(:users, type: :uuid, on_delete: :nothing)
    end

    create unique_index(:stores, [:user_id], name: :stores_user_id_fkey)
  end
end
