defmodule VocialWeb.PageControllerTest do
  use VocialWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get conn, "/"
    assert html_response(conn, 200) =~ "Vocial"
  end
end
