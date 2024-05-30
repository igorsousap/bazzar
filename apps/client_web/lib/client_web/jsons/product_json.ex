defmodule ClientWeb.Jsons.ProductJson do
  def product(%{product: product}) do
    %{
      product_name: product.product_name,
      description: product.description,
      cod_product: product.cod_product,
      size: product.size,
      value: product.value,
      quantity: product.quantity
    }
  end

  def product_index(%{product: product}) do
    Enum.map(product, fn product ->
      %{
        product_name: product.product_name,
        description: product.description,
        cod_product: product.cod_product,
        size: product.size,
        value: product.value,
        quantity: product.quantity
      }
    end)
  end
end
