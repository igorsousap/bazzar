defmodule Persistence.Users.UsersTest do
  use Persistence.DataCase, async: false

  import Persistence.Factory

  alias Persistence.Users.Users

  @moduletag :capture_log

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
    attrs = params_for(:user)
    {:ok, user} = Users.register_user(attrs)
    {:ok, user: user, attrs: attrs}
  end

  describe "register_user/1" do
    test "should return register user in database" do
      user = params_for(:user, email: "new_email-test@mail.com")
      assert {:ok, %Persistence.Users.Schema.User{}} = Users.register_user(user)
    end

    test "should return a error in changeset when pass a wrong password" do
      user =
        params_for(:user, password: "testwithoutuppercase123@", email: "new_email-test@mail.com")

      assert {:error, changeset} = Users.register_user(user)
      assert %{password: ["at least one upper case character"]} == errors_on(changeset)
    end
  end

  describe "get_user_by_id/1" do
    test "should return a user when given a id", %{user: user} do
      assert %Persistence.Users.Schema.User{} = Users.get_user_by_id(user.id)
    end

    test "should return a error in changeset when id dosent exists", %{user: _user} do
      assert nil == Users.get_user_by_id(Ecto.UUID.autogenerate())
    end
  end

  describe "get_user_by_email_and_password/1" do
    test "should return a user when given email and password", %{attrs: attrs} do
      assert {:ok, %Persistence.Users.Schema.User{}} =
               Users.get_user_by_email_and_password(attrs.email, attrs.password)
    end

    test "should return a error in changeset when dosent exist user with email or password" do
      assert nil == Users.get_user_by_email_and_password("test_error@mail.com", "Password321@")
    end
  end

  describe "change_user_email/2" do
    test "should return updated user with new email", %{attrs: attrs} do
      assert {:ok, %Persistence.Users.Schema.User{}} =
               Users.change_user_email(attrs.cpf, %{email: "Newemail@mail.com"})
    end

    test "should return a error when not found the user" do
      assert {:error, :not_found} ==
               Users.change_user_email(Brcpfcnpj.cpf_generate(), %{email: "Newemail@123"})
    end

    test "should return a error when email is invalid", %{attrs: attrs} do
      assert {:error, changeset} =
               Users.change_user_email(attrs.cpf, %{email: "wrong_email"})

      assert %{email: ["must have the @ sign and no spaces"]} == errors_on(changeset)
    end
  end

  describe "change_user_password/2" do
    test "should return updated user with new password", %{attrs: attrs} do
      assert {:ok, %Persistence.Users.Schema.User{}} =
               Users.change_user_password(attrs.cpf, %{password: "Newpassword123@"})
    end

    test "should return a error when not found the user" do
      assert {:error, :not_found} ==
               Users.change_user_password(Brcpfcnpj.cpf_generate(), %{password: "Newpassword123@"})
    end

    test "should return a error when password is invalid", %{attrs: attrs} do
      assert {:error, changeset} =
               Users.change_user_password(attrs.cpf, %{password: "newpassword123@"})

      assert %{password: ["at least one upper case character"]} == errors_on(changeset)
    end
  end

  describe "verify_token/1" do
    test "should return a user when token is valid", %{user: user} do
      assert {:ok, %Persistence.Users.Schema.User{}} =
               Users.verify_token(user.id)
    end
  end
end
