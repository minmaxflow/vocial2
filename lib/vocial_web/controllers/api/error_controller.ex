defmodule VocialWeb.Api.ErrorController do 
  use VocialWeb, :controller

  def call(conn, {:error, :not_found}) do 
    conn
    |> put_status(:nout_found)
    |> render(VocialWeb.ErrorView, "404.json")
  end

  def call(conn, _) do 
    conn 
    |> put_status(500)
    |> render(VocialWeb.ErrorView, "500.json")
  end

end