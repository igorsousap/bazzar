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
      add :cep, :string, required: true
      add :cnpj, :string, required: true
      add :phone, :string, require: true

      timestamps()
    end

    create unique_index(:stores, [:name_store], name: :store_name_index)
    create unique_index(:stores, [:cnpj], name: :store_cnpj_index)
  end
end
