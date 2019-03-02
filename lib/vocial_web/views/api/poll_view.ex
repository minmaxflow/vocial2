defmodule VocialWeb.Api.PollView do 
  use VocialWeb, :view 

  def render("index.json", %{polls: polls}) do 
    %{
      polls: render_many(polls)
    }
  end

  def render("show.json", %{poll: poll}) do 
    %{
      poll: render_one(poll)
    }
  end

  def render_many(polls) do 
    Enum.map(polls, &render_one/1)
  end

  def render_one(poll) do 
    %{
      id: poll.id,
      title: poll.title,
      options: render_options(poll.options),
      image: render_image(poll.image)
    }
  end

  def render_options(nil), do: []
  def render_options(options) do 
    options 
    |> Enum.map(fn o -> Map.take(o, [:title, :votes]) end)
  end

  def render_image(nil), do: nil
  def render_iamge(image) do 
    %{
      url: image.url,
      alt: image.alt,
      caption: image.caption
    }
  end
end