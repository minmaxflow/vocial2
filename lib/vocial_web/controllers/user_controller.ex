defmodule VocialWeb.UserController do 
  use VocialWeb, :controller 

  alias Vocial.Accounts

  def new(conn, _) do 
    user = Accounts.new_user
    render(conn, "new.html", user: user)
  end

  def create(conn, %{"user" => user_params}) do 
    with {:ok, user} <- Accounts.create_user(user_params) do 
      conn 
      |> put_flash(:info, "User created")
      |> redirect(to: user_path(conn, :show, user))
    else
      {:error, user} ->
        conn
        |> put_flash(:error, "Faild to create user!")
        |> render("new.html", user: user)
    end
  end

  def show(conn, %{"id" => id}) do 
    with user <- Accounts.get_user(id) do 
      render(conn, "show.html", user: user)
    end
  end

  def generate_api_key(conn, %{"id" => id}) do 
    user = Accounts.get_user(id)

    case Accounts.generate_api_key(user) do 
      {:ok, _} -> 
          conn 
          |> put_flash(:info, "Update API key for user!")
          |> redirect(to: user_path(conn, :show, user))
      {:error, _} -> 
          conn 
          |> put_flash(:error, "Failed to generate API key for user!")
          |> redirect(to: user_path(conn, :show, user))
    end
  end
  
end