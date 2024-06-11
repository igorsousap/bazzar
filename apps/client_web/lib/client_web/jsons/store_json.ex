defmodule ClientWeb.Jsons.StoreJson do
  def store(%{store: store}) do
    %{
      name_store: store.name_store,
      cnpj: store.cnpj
    }
  end

  def store_pagination(%{store: store}) do
    Enum.map(store, fn x ->
      %{
        name_store: x.name_store,
        cnpj: x.cnpj
      }
    end)
  end
end
