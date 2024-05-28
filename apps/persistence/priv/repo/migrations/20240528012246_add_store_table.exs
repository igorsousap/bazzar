defmodule Persistence.Repo.Migrations.AddStoreTable do
  use Ecto.Migration

  def change do
    create table(:stores, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :name_store, :string, required: true
      add :description, :text, required: true
      add :adress, :string, required: true
      add :neighborhood, :string, required: true
      add :number, :integer, required: true
      add :cep, :integer, required: true
      add :cnpj, :integer, required: true

      timestamps()
    end

    create unique_index(:stores, [:name_store, :cnpj],
             name: :name_store_index,
             name: :cnpj_store_index
           )
  end
end
