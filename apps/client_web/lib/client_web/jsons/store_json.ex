defmodule ClientWeb.Jsons.StoreJson do
  def store(%{store: store}) do
    IO.inspect(store, label: :store)
    "Store #{store.name_store} was been created"
  end
end
