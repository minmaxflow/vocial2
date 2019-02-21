defmodule Vocial.AccountsTest do 
  use Vocial.DataCase 

  alias Vocial.Accounts

  describe "users" do
    @valid_attrs %{username: "test", email: "test@test.com", active: true}

    def user_fixture(attrs \\ %{}) do 
      with create_attrs <- Map.merge(@valid_attrs, attrs),
          {:ok, user} <- Accounts.create_user(create_attrs)
      do 
        user
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

  end
end