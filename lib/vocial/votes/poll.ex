defmodule Vocial.Votes.Poll do 
  use Ecto.Schema
  import Ecto.Changeset
  alias Vocial.Votes.{Poll, Option, Image}
  alias Vocial.Accounts.User

  schema "polls" do 
    field :title, :string

    belongs_to :user, User
    has_many :options, Option
    has_one :image, Image

    timestamps()
  end

  def chageset(%Poll{} = poll, attrs) do 
    poll
    |>cast(attrs, [:title, :user_id])
    |>validate_required([:title, :user_id])
  end

end