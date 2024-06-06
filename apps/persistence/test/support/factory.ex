defmodule Persistence.Factory do
  use ExMachina.Ecto, repo: Persistence.Repo

  def store_factory do
    %{
      id: Ecto.UUID.autogenerate(),
      name_store: "teststore",
      description: "Store for test",
      adress: "Street test",
      neighborhood: "Center district",
      number: 123,
      cep: "55608-760",
      cnpj: Brcpfcnpj.cnpj_generate(),
      phone: "88999999999"
    }
  end

  def product_factory do
    %{
      product_name: "T-Shirt Adidas",
      description: "dryfit t-shirt",
      cod_product: "7898357411232",
      size: "xs",
      value: 105.99,
      quantity: 100,
      picture: "www.linkimage.com"
    }
  end

  def user_factory do
    %{
      first_name: "First Name",
      last_name: "Last Name",
      cpf: Brcpfcnpj.cpf_generate(),
      email: "test@email.com",
      password: "Password123@",
      confirmed_at: NaiveDateTime.local_now()
    }
  end
end
