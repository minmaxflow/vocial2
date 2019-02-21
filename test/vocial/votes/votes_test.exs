defmodule Vocial.VotesTest do 
  use Vocial.DataCase 

  alias Vocial.Votes

  describe "polls" do
    @valid_attrs %{title: "Hello"}

    def poll_fixture(attrs \\ %{}) do 
      with create_attrs <- Enum.into(attrs, @valid_attrs), 
           {:ok, poll} <- Votes.create_poll(create_attrs),
           poll <- Repo.preload(poll, [:options])
      do
        poll
      end 
    end

    test "list_polls/0 return all polls" do 
      poll = poll_fixture()
      assert Votes.list_polls() == [poll]
    end

    test "new_poll/0 return a new blank chageset" do 
      changeset = Votes.new_poll()
      assert changeset.__struct__ == Ecto.Changeset
    end

    test "create_poll/1 return a new poll" do 
      {:ok, poll} = Votes.create_poll(@valid_attrs)
      assert Enum.any?(Votes.list_polls(), fn p -> p.id == poll.id end)
    end

    test "create_poll_with_options/2 returns a new poll with options" do 
      title = "poll with options"
      options = ["a", "b", "c"]
      {:ok, poll} = Votes.create_poll_with_options(%{title: title}, options)
      assert poll.title == title
      assert Enum.count(poll.options) == 3
    end

    test "create_poll_with_options/2 does not create the poll or options with bad data" do 
      title = "Bad Poll"
      {status, _} = Votes.create_poll_with_options(%{title: title}, ["a", nil, "b"])
      assert status == :error
      assert !Enum.any?(Votes.list_polls(), fn p -> p.title == title end)
    end
  end

  describe "options" do
    test "create_option/1 create an option on a poll" do 
      with {:ok, poll} <- Votes.create_poll(%{title: "Title"}),
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

end