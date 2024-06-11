defmodule Persistence.Factory do
  use ExMachina.Ecto, repo: Persistence.Repo

  alias Persistence.Stores.Schema.Store
  alias Persistence.Products.Schema.Product
  alias Persistence.Users.Schema.User

  @min 10_000_000_000_000
  @max 99_999_999_999_999

  def store_factory do
    %Store{
      name_store: "teststore",
      description: "Store for test",
      adress: "Street test",
      user_id: nil,
      neighborhood: "Center district",
      number: 123,
      cep: "55608-760",
      cnpj: Brcpfcnpj.cnpj_generate(),
      phone: "88999999999"
    }
  end

  def product_factory do
    %Product{
      product_name: "T-Shirt Adidas",
      description: "dryfit t-shirt",
      cod_product: Integer.to_string(:rand.uniform(@max - @min + 1) + @min - 1),
      size: "xs",
      value: 105.99,
      quantity: 100,
      picture: "www.linkimage.com"
    }
  end

  def user_factory do
    %User{
      first_name: "First Name",
      last_name: "Last Name",
      cpf: Brcpfcnpj.cpf_generate(),
      email: "test@email.com",
      password: "Password123@",
      hashed_password: Bcrypt.hash_pwd_salt("Password123@"),
      confirmed_at: NaiveDateTime.local_now()
    }
  end
end
