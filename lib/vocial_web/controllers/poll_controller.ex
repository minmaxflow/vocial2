defmodule VocialWeb.PollController do 
  use VocialWeb, :controller 

  alias Vocial.Votes

  plug VocialWeb.VerifyUserSession when action in [:new, :create]  

  # http://localhost:4000/polls?page=3&per_page=2
  def index(conn, params) do 
    %{"page" => page, "per_page" => per_page} = normalize_paging_params(params)
    polls = Votes.list_most_recent_polls_with_extra(page, per_page)
    opts = paging_options(polls, page, per_page)
    render(conn, "index.html", polls: Enum.take(polls, per_page), opts: opts)
  end

  def new(conn, _params) do 
    poll = Votes.new_poll()
    render(conn, "new.html", poll: poll)
  end

  def create(conn, %{"poll" => poll_params, "options" => options, "image_data" => image_data}) do 
    split_options = String.split(options, ",")
    with user <- get_session(conn, :user),
         poll_params <- Map.put(poll_params, "user_id", user.id),
      {:ok, _poll} <- Votes.create_poll_with_options(poll_params, split_options, image_data) 
    do 
      conn 
      |> put_flash(:info, "Poll created successfully!")
      |> redirect(to: poll_path(conn, :index))
    else
      {:error, _poll} -> 
        conn
        |> put_flash(:alert, "Error creating poll!")
        |> redirect(to: poll_path(conn, :new))
    end
  end

  # 要放在最后，避免死循坏
  def create(conn, %{"poll" => _poll_params, "options" => _options} = params) do 
    create(conn, Map.put(params, "image_data", nil))
  end  

  def show(conn, %{"id" => id}) do 
    with poll <- Votes.get_poll(id) do
      render(conn, "show.html", %{poll: poll})
    end
  end

  def vote(conn, %{"id" => id}) do 
    voter_ip = conn.remote_ip 
               |> Tuple.to_list()
               |> Enum.join(".")
    with {:ok, option} <- Votes.vote_on_option(id, voter_ip) do 
      conn 
      |> put_flash(:info, "Placed a vote for #{option.title}")\
      |> redirect(to: poll_path(conn, :index))
    else 
      _ -> conn
           |> put_flash(:error, "Could not vote!")
           |> redirect(to: poll_path(conn, :index)) 
    end
  end

  # paging 
  defp paging_params(%{"page" => page, "per_page" => per_page}) do 
    page = case is_binary(page) do 
      true -> String.to_integer(page)
      _ -> page
    end
    per_page = case is_binary(per_page) do 
      true -> String.to_integer(per_page)
      _ -> per_page
    end
    # 前端假设从1开始分页
    %{"page" => page - 1, "per_page" => per_page}
  end

  defp normalize_paging_params(params) do 
    %{"page" => 1, "per_page" => 25}
    |> Map.merge(params)
    |> paging_params()
  end

  # 比per_page多请求一个数据，这样能判断是否还有数据
  defp paging_options(polls, page, per_page) do 
    %{
      include_next_page: Enum.count(polls) > per_page,
      include_prev_page: page > 0, 
      # 前端从1开始分页
      page: page + 1,
      per_page: per_page
    }
  end

end