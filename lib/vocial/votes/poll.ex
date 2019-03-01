defmodule Vocial.Votes.Poll do 
  use Ecto.Schema
  import Ecto.Changeset
  alias Vocial.Votes.{Poll, Option, Image, VoteRecord, Message}
  alias Vocial.Accounts.User

  schema "polls" do 
    field :title, :string

    belongs_to :user, User
    has_many :options, Option
    has_one :image, Image
    has_many :vote_records, VoteRecord
    has_many :messages, Message

    timestamps()
  end

  def chageset(%Poll{} = poll, attrs) do 
    poll
    |>cast(attrs, [:title, :user_id])
    |>validate_required([:title, :user_id])
  end

end