defmodule Vocial.AccountsTest do 
  use Vocial.DataCase 

  alias Vocial.Accounts

  describe "users" do
    @valid_attrs %{username: "test", email: "test@test.com", active: true, password: "test", password_confirmation: "test"}

    def user_fixture(attrs \\ %{}) do 
      with create_attrs <- Map.merge(@valid_attrs, attrs),
          {:ok, user} <- Accounts.create_user(create_attrs)
      do 
        user |> Map.merge(%{password: nil, password_confirmation: nil})
      end
    end

    test "list_users/0 returns all users" do 
      user = user_fixture()
      assert Accounts.list_user() == [user]
    end

    test "get_user/1 return the user with the id" do 
      user = user_fixture()
      assert Accounts.get_user(user.id) == user
    end

    test "new_user/0 return a blank changeset" do 
      changeset = Accounts.new_user()
      assert changeset.__struct__ == Ecto.Changeset
    end

    test "create_user/1 creates the user in the db and returns it" do 
      before = Accounts.list_user()
      user = user_fixture()
      updated = Accounts.list_user()
      assert !Enum.any?(before, fn u -> user == u end)
      assert Enum.any?(updated, fn u -> user == u end)
    end

    test "create_user/1 fails to create the user without a password and password_confirmation" do 
      {:error, changeset} = user_fixture(%{password: nil, password_confirmation: nil})
      assert !changeset.valid?
    end

    test "create_user/1 fails to create the user when the password and the password_confirmation don't match" do 
      {:error, changeset} = user_fixture(%{password: "test", password_confirmation: "test2"})
      assert !changeset.valid?
    end

    test "get_user_by_username/1 returns the user with the matching username" do 
      user = user_fixture()
      assert Accounts.get_user_by_username(user.username)
    end

    test "get_user_by_username/1 return nil"  do
      assert is_nil(Accounts.get_user_by_username("fail"))
    end

    test "create_user/1 fails to create the user when the username alread exists" do 
      _user1 = user_fixture()
      {:error, user2} = user_fixture()
      assert !user2.valid?
    end

    test "create_user/1 fails to create the user when email is not an email format" do 
      {:error, user} = user_fixture(%{email: "testemail"})
      assert !user.valid?
    end

    test "create_user/1 fails to create the user when email is fake" do 
      {:error, user} = user_fixture(%{email: "test@fake.com"})
      assert !user.valid?
    end

    test "create_user/1 fails to create the user when the username is too short" do 
      {:error, user} = user_fixture(%{username: "a"})
      assert !user.valid?
    end

  end
end