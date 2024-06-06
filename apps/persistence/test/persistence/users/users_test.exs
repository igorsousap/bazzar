defmodule Persistence.Users.UsersTest do
  use Persistence.DataCase, async: false

  import Persistence.Factory

  alias Persistence.Users.Users
  alias Persistence.Users.Schema.User

  @moduletag :capture_log

  setup_all do
    user = build(:user)
    {:ok, user: user}
  end

  describe "register_user/1" do
    test "should return register user in database", %{user: user} do
      assert {:ok, %Persistence.Users.Schema.User{}} = Users.register_user(user)
    end

    test "should return a error in changeset", %{user: _user} do
      user = build(:user, password: "testwithoutuppercase123@")
      assert {:error, changeset} = Users.register_user(user)
      assert %{password: ["at least one upper case character"]} == errors_on(changeset)
    end
  end

  describe "get_user_by_id/1" do
    test "should return a user when given a id", %{user: user} do
      {:ok, user_data} = Users.register_user(user)
      assert %Persistence.Users.Schema.User{} = Users.get_user_by_id(user_data.id)
    end

    test "should return a error in changeset when id dosent exists", %{user: _user} do
      assert nil == Users.get_user_by_id(Ecto.UUID.autogenerate())
    end
  end

  describe "get_user_by_email_and_password/1" do
    test "should return a user when given email and password", %{user: user} do
      {:ok, user_data} = Users.register_user(user)

      assert {:ok, %Persistence.Users.Schema.User{}} =
               Users.get_user_by_email_and_password(user_data.email, "Password123@")
    end

    test "should return a error in changeset when dosent exist user with email or password", %{
      user: _user
    } do
      assert nil == Users.get_user_by_email_and_password("test_error@mail.com", "Password321@")
    end
  end

  describe "change_user_email/2" do
    test "should return updated user with new email", %{user: user} do
      {:ok, user_data} = Users.register_user(user)

      assert {:ok, %Persistence.Users.Schema.User{}} =
               Users.change_user_email(user_data.cpf, %{email: "Newemail@mail.com"})
    end

    test "should return a error when not found the user", %{
      user: _user
    } do
      assert {:error, :not_found} ==
               Users.change_user_email(Brcpfcnpj.cpf_generate(), %{email: "Newemail@123"})
    end

    test "should return a error when email is invalid", %{
      user: user
    } do
      {:ok, user_data} = Users.register_user(user)

      assert {:error, changeset} =
               Users.change_user_email(user_data.cpf, %{email: "wrong_email"})

      assert %{email: ["must have the @ sign and no spaces"]} == errors_on(changeset)
    end
  end

  describe "change_user_password/2" do
    test "should return updated user with new password", %{user: user} do
      {:ok, user_data} = Users.register_user(user)

      assert {:ok, %Persistence.Users.Schema.User{}} =
               Users.change_user_password(user_data.cpf, %{password: "Newpassword123@"})
    end

    test "should return a error when not found the user", %{
      user: _user
    } do
      assert {:error, :not_found} ==
               Users.change_user_password(Brcpfcnpj.cpf_generate(), %{password: "Newpassword123@"})
    end

    test "should return a error when password is invalid", %{
      user: user
    } do
      {:ok, user_data} = Users.register_user(user)

      assert {:error, changeset} =
               Users.change_user_password(user_data.cpf, %{password: "newpassword123@"})

      assert %{password: ["at least one upper case character"]} == errors_on(changeset)
    end
  end
end
