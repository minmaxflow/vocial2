defmodule Vocial.VotesTest do 
  use Vocial.DataCase 

  alias Vocial.Votes

  setup do 
    {:ok, user} = Vocial.Accounts.create_user(%{
      username: "test",
      email: "test@test.com",
      password: "test",
      password_confirmation: "test"
    })
    {:ok, user: user}
  end

  describe "polls" do
    @valid_attrs %{title: "Hello"}

    def poll_fixture(attrs \\ %{}) do 
      with create_attrs <- Enum.into(attrs, @valid_attrs), 
           {:ok, poll} <- Votes.create_poll(create_attrs),
           poll <- Repo.preload(poll, [:options, :image, :vote_records, :messages])
      do
        poll
      end 
    end

    test "list_polls/0 return all polls", %{user: user} do 
      poll = poll_fixture(%{user_id: user.id})
      assert Votes.list_polls() == [poll]
    end

    test "list_most_recent_polls/2 returns polls ordered by the most recent first", %{user: user} do 
      poll = poll_fixture(%{user_id: user.id})
      poll2 = poll_fixture(%{user_id: user.id})
      poll3 = poll_fixture(%{user_id: user.id})
      assert Votes.list_most_recent_polls() == [poll3, poll2, poll]
    end

    test "list_most_recent_polls/2 returns polls ordered and paged correctly", %{user: user} do 
      _poll = poll_fixture(%{user_id: user.id})
      _poll2 = poll_fixture(%{user_id: user.id})
      poll3 = poll_fixture(%{user_id: user.id})
      _poll4 = poll_fixture(%{user_id: user.id})
      assert Votes.list_most_recent_polls(1, 1) == [poll3]
    end

    test "list_most_recent_polls_with_extra/2 returns polls ordered and paged correctly", %{user: user} do 
      _poll = poll_fixture(%{user_id: user.id})
      poll2 = poll_fixture(%{user_id: user.id})
      poll3 = poll_fixture(%{user_id: user.id})
      _poll4 = poll_fixture(%{user_id: user.id})
      assert Votes.list_most_recent_polls_with_extra(1, 1) == [poll3, poll2]
    end

    test "new_poll/0 return a new blank chageset" do 
      changeset = Votes.new_poll()
      assert changeset.__struct__ == Ecto.Changeset
    end

    test "create_poll/1 return a new poll", %{user: user} do 
      {:ok, poll} = Votes.create_poll(Map.put(@valid_attrs, :user_id, user.id))
      assert Enum.any?(Votes.list_polls(), fn p -> p.id == poll.id end)
    end

    test "create_poll_with_options/2 returns a new poll with options", %{user: user} do 
      title = "poll with options"
      options = ["a", "b", "c"]
      {:ok, poll} = Votes.create_poll_with_options(%{title: title, user_id: user.id}, options)
      assert poll.title == title
      assert Enum.count(poll.options) == 3
    end

    test "create_poll_with_options/2 does not create the poll or options with bad data", %{user: user} do 
      title = "Bad Poll"
      {status, _} = Votes.create_poll_with_options(%{title: title, user_id: user.id}, ["a", nil, "b"])
      assert status == :error
      assert !Enum.any?(Votes.list_polls(), fn p -> p.title == title end)
    end

    test "get_poll/1 returns a specific poll", %{user: user} do 
      poll = poll_fixture(%{user_id: user.id})
      assert Votes.get_poll(poll.id) == poll
    end
  end

  describe "options" do
    test "create_option/1 create an option on a poll", %{user: user}do 
      with {:ok, poll} <- Votes.create_poll(%{title: "Title", user_id: user.id}),
           {:ok, option} <- Votes.create_option(%{title: "Sample Choice", votes: 0, poll_id: poll.id}),
           option <- Repo.preload(option, [:poll])
      do 
        assert Votes.list_options() == [option]
      else 
        # need pattern matching 
        _ -> assert false
      end
    end
  end

  test "vote_on_option/1 adds a vote to a particular option", %{user: user} do 
    with {:ok, poll} = Votes.create_poll(%{title: "Sample Poll", user_id: user.id}),
         {:ok, option} = Votes.create_option(%{title: "Sample Choice", votes: 0, poll_id: poll.id}),
         option <- Repo.preload(option, [:poll])
    do 
      votes_before = option.votes
      {:ok, updated_option} = Votes.vote_on_option(option.id, "127.0.0.1")
      assert (votes_before + 1) == updated_option.votes
    end
  end

  describe "messages" do
    setup %{user: user}do 
      {:ok, poll} = Votes.create_poll(%{title: "Sample Poll", user_id: user.id})
      poll_messages = ["Hello", "there", "world"]
      lobby_messages = ["Polls", "are", "neat"]

      Enum.each(poll_messages, fn m -> 
        Votes.create_message(%{message: m, author: "Someone", poll_id: poll.id})
      end)
      Enum.each(lobby_messages, fn m -> 
        Votes.create_message(%{message: m, author: "Someone"})
      end)
      
      {:ok, poll: poll}
    end

    test "create_message/1 creates a message on a poll" do 
      with {:ok, message} <- Votes.create_message(%{message: "Hello Wordl", author: "Someone"}) do
        assert Enum.any?(Votes.list_lobby_messages(), fn m -> m.id == message.id end)
      end
    end

    test "list_lobby_message/1 only include lobby message" do 
      assert Enum.count(Votes.list_lobby_messages()) > 0
      assert Enum.all?(Votes.list_lobby_messages(), &(is_nil(&1.poll_id)))
    end

    test "list_poll_messages/1 only include poll message", %{poll: poll} do 
      assert Enum.count(Votes.list_poll_messages(poll.id)) > 0
      assert Enum.all?(Votes.list_poll_messages(poll.id), fn m -> m.poll_id == poll.id end )
    end

  end

end