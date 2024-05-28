defmodule Persistence.Repo.Migrations.AddProductTable do
  use Ecto.Migration

  def change do
    create_size_types_enum()

    create table(:products, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :product_name, :string, required: true
      add :cod_product, :string, require: true

      add :id_store,
          references(:stores, on_delete: :delete_all, column: :id, type: :uuid),
          null: false

      add :description, :text, required: true
      add :size, :string, required: true
      add :value, :decimal, required: true
      add :quantity, :integer, required: true
      add :picture, :string, required: true

      timestamps()
    end

    create unique_index(:products, [:cod_product], name: :cod_product_index)
  end

  defp create_size_types_enum do
    query_create_type = "CREATE TYPE size AS ENUM ('xs', 's', 'm', 'l', 'xl', 'xxl', 'xxxl')"

    query_create_type_rollback = "DROP TYPE size"

    execute query_create_type, query_create_type_rollback
  end
end
