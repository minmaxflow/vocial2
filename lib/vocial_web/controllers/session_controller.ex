defmodule VocialWeb.SessionController do 
  use VocialWeb, :controller 

  alias Vocial.Accounts

  plug Ueberauth

  def new(conn, _) do 
    render(conn, "new.html")
  end

  def delete(conn, _) do 
    conn 
    |> delete_session(:user)
    |> put_flash(:info, "Logged out successfully!")
    |> redirect(to: "/")
  end

  def create(conn, %{"username" => username, "password" => password}) do 
    with user <- Accounts.get_user_by_username(username),
         {:ok, login_user} <-  login(user, password)
    do 
      conn 
      |> put_flash(:info, "Logged in successfully!")
      |> put_session(:user, %{id: login_user.id, username: login_user.username, email: login_user.email})
      |> redirect(to: "/")
    else
      {:error, _} -> 
        conn 
        |> put_flash(:error, "Invalid username/password!")
        |> render("new.html")
    end
  end

  defp login(user, password) do 
    Comeonin.Bcrypt.check_pass(user, password)
  end

  def callback(%{assigns: %{ueberauth_failure: _fails}} = conn, _params) do 
    conn 
    |> put_flash(:error, "Failed to authenticate")
    |> redirect(to: "/")
  end

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do 
    case find_or_create_user(auth) do 
      {:ok, user} -> 
        conn 
        |> put_flash(:info, "Logged in successfully!")
        |> put_session(:user, %{id: user.id, username: user.username, email: user.email})
        |> redirect(to: "/")
      {:error, reason} -> 
        conn 
        |> put_flash(:error, reason)
        |> redirect(to: "/")
    end
  end

  defp find_or_create_user(auth) do 
    user = build_userr_from_auth(auth)
    case Accounts.get_user_by_oauth(user.oauth_provider, user.oauth_id) do 
      user -> {:ok, user}
      nil -> 
        case Accounts.get_user_by_username(user.username) do 
          nil -> Accounts.create_user(user)
          _ -> Accounts.create_user(%{user | username: "#{user.username}#{user.oauth_id}"})
        end
    end
  end

  defp build_userr_from_auth(%{provider: :google}=auth) do 
    password = Accounts.random_string(64)
    %{
      username: auth.info.email,
      email: auth.info.email,
      oauth_id: auth.uid,
      oauth_provider: "google",
      password: password,
      password_confirmation: password
    }
  end

end