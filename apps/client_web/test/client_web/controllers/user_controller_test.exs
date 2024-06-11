defmodule ClientWeb.UserControllerTest do
  use ClientWeb.ConnCase, async: true

  import Persistence.Factory

  alias ClientWeb.Guardian
  alias Persistence.Users.Users

  @moduletag :capture_log

  setup %{conn: conn} do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Persistence.Repo)
    attrs_user = params_for(:user)
    {:ok, user} = Users.register_user(attrs_user)
    {:ok, token, _claims} = Guardian.encode_and_sign(user)

    conn =
      conn
      |> put_req_header("accept", "application/json")
      |> put_req_header("authorization", "Bearer #{token}")

    {:ok, attrs: attrs_user, conn: conn}
  end

  describe "create/2" do
    test "should return 201 and user details", %{attrs: attrs_user, conn: conn} do
      attrs_user = %{attrs_user | email: "new_email@mail.com", cpf: Brcpfcnpj.cpf_generate()}

      response =
        conn
        |> post(~p"/api/user/", attrs_user)
        |> json_response(:created)

      assert %{
               "cpf" => attrs_user.cpf,
               "email" => "new_email@mail.com",
               "user" => "First Name Last Name"
             } == response
    end

    test "should return 422 if cpf alredy been take", %{attrs: attrs_user, conn: conn} do
      attrs_user = %{attrs_user | email: "email@mail.com"}

      response =
        conn
        |> post(~p"/api/user/", attrs_user)
        |> json_response(:unprocessable_entity)

      assert %{"errors" => %{"cpf" => ["has already been taken"]}} == response
    end

    test "should return 422 if email alredy been take", %{attrs: attrs_user, conn: conn} do
      response =
        conn
        |> post(~p"/api/user/", attrs_user)
        |> json_response(:unprocessable_entity)

      assert %{"errors" => %{"email" => ["has already been taken"]}} == response
    end

    test "should return 422 if required params not given", %{attrs: attrs_user, conn: conn} do
      attrs_user = %{attrs_user | email: nil}

      response =
        conn
        |> post(~p"/api/user/", attrs_user)
        |> json_response(:unprocessable_entity)

      assert %{"errors" => %{"email" => ["can't be blank"]}} == response
    end
  end

  describe "get_user/2" do
    test "should return 200 and user from database", %{attrs: attrs_user, conn: conn} do
      response =
        conn
        |> get(~p"/api/user/?email=#{attrs_user.email}&password=#{attrs_user.password}")
        |> json_response(:ok)

      assert %{
               "cpf" => attrs_user.cpf,
               "email" => "test@email.com",
               "user" => "First Name Last Name"
             } == response
    end

    test "should return 422 when pass a non exiting user", %{conn: conn} do
      response =
        conn
        |> get(~p"/api/user/?email=emai@test.com&password=Atesterror@123")
        |> json_response(:not_found)

      assert %{"errors" => "Not Found"} == response
    end
  end

  describe "change_email_or_password/2" do
    test "should return 204 and update a user email", %{attrs: attrs_user, conn: conn} do
      attrs = %{
        "cpf" => attrs_user.cpf,
        "email" => "new_test@mail.com"
      }

      response =
        conn
        |> put(~p"/api/user/", attrs)
        |> json_response(:ok)

      assert %{
               "cpf" => attrs_user.cpf,
               "email" => "new_test@mail.com",
               "user" => "First Name Last Name"
             } == response
    end

    test "should return 204 and update a user password", %{attrs: attrs_user, conn: conn} do
      attrs = %{
        "cpf" => attrs_user.cpf,
        "password" => "Newpassword@123"
      }

      response =
        conn
        |> put(~p"/api/user/", attrs)
        |> json_response(:ok)

      assert %{
               "cpf" => attrs_user.cpf,
               "email" => "test@email.com",
               "user" => "First Name Last Name"
             } == response
    end

    test "should return 422 a error not found", %{conn: conn} do
      attrs = %{
        "cpf" => "9999999999",
        "password" => "Newpassword@123"
      }

      response =
        conn
        |> put(~p"/api/user/", attrs)
        |> json_response(:not_found)

      assert %{"errors" => "Not Found"} == response
    end
  end

  describe "generate_new_token/2" do
    test "should return 201 and update a new token", %{attrs: attrs_user, conn: conn} do
      attrs = %{
        "email" => attrs_user.email,
        "password" => attrs_user.password
      }

      response =
        conn
        |> post(~p"/api/user/new-token", attrs)
        |> json_response(:ok)

      assert %{
               "cpf" => attrs_user.cpf,
               "email" => "test@email.com",
               "user" => "First Name Last Name"
             } == response
    end

    test "should return 422 and a error", %{attrs: attrs_user, conn: conn} do
      attrs = %{
        "email" => "email_test@mail.com",
        "password" => attrs_user.password
      }

      response =
        conn
        |> post(~p"/api/user/new-token", attrs)
        |> json_response(:not_found)

      assert %{"errors" => "Not Found"} == response
    end
  end
end
