defmodule Vocial.Accounts do 
  import Ecto.Query, warn: false 
  
  alias Vocial.Repo 
  alias Vocial.Accounts.User

  def list_user do
    Repo.all(User)
  end

  def new_user do 
    User.changeset(%User{}, %{})
  end

  def create_user(attrs \\ %{}) do 
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  def get_user(id) do 
    Repo.get(User, id)
  end

end