defmodule Chatapp.ChatRooms do
  @moduledoc """
  The ChatRooms context.
  """

  import Ecto.Query, warn: false
  alias Chatapp.Repo

  alias Chatapp.ChatRooms.ChatRoom
  alias Chatapp.ChatRooms.ChatRoomMember
  alias Chatapp.Accounts.User

  @doc """
  Returns the list of chat_rooms.

  ## Examples

      iex> list_chat_rooms()
      [%ChatRoom{}, ...]

  """
  def list_chat_rooms do
    Repo.all(ChatRoom)
  end

  @doc """
  Gets a single chat_room.

  Raises `Ecto.NoResultsError` if the Chat room does not exist.

  ## Examples

      iex> get_chat_room!(123)
      %ChatRoom{}

      iex> get_chat_room!(456)
      ** (Ecto.NoResultsError)

  """
  def get_chat_room!(id), do: Repo.get!(ChatRoom, id)

  @doc """
  Gets a single chat_room with preloaded associations.

  ## Examples

      iex> get_chat_room_with_users!(123)
      %ChatRoom{users: [...]}

  """
  def get_chat_room_with_users!(id) do
    ChatRoom
    |> Repo.get!(id)
    |> Repo.preload(:users)
  end

  @doc """
  Creates a chat_room.

  ## Examples

      iex> create_chat_room(%{field: value})
      {:ok, %ChatRoom{}}

      iex> create_chat_room(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_chat_room(attrs \\ %{}) do
    %ChatRoom{}
    |> ChatRoom.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a chat_room.

  ## Examples

      iex> update_chat_room(chat_room, %{field: new_value})
      {:ok, %ChatRoom{}}

      iex> update_chat_room(chat_room, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_chat_room(%ChatRoom{} = chat_room, attrs) do
    chat_room
    |> ChatRoom.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a chat_room.

  ## Examples

      iex> delete_chat_room(chat_room)
      {:ok, %ChatRoom{}}

      iex> delete_chat_room(chat_room)
      {:error, %Ecto.Changeset{}}

  """
  def delete_chat_room(%ChatRoom{} = chat_room) do
    Repo.delete(chat_room)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking chat_room changes.

  ## Examples

      iex> change_chat_room(chat_room)
      %Ecto.Changeset{data: %ChatRoom{}}

  """
  def change_chat_room(%ChatRoom{} = chat_room, attrs \\ %{}) do
    ChatRoom.changeset(chat_room, attrs)
  end

  @doc """
  Adds a user to a chat room.

  ## Examples

      iex> join_chat_room(chat_room, user)
      {:ok, %ChatRoom{}}

      iex> join_chat_room(chat_room, user)
      {:error, %Ecto.Changeset{}}

  """
  def join_chat_room(%ChatRoom{} = chat_room, %User{} = user) do
    chat_room = Repo.preload(chat_room, :users)

    if user in chat_room.users do
      {:ok, chat_room}
    else
      chat_room
      |> Ecto.Changeset.change()
      |> Ecto.Changeset.put_assoc(:users, [user | chat_room.users])
      |> Repo.update()
    end
  end

  @doc """
  Removes a user from a chat room.

  ## Examples

      iex> leave_chat_room(chat_room, user)
      {:ok, %ChatRoom{}}

  """
  def leave_chat_room(%ChatRoom{} = chat_room, %User{} = user) do
    chat_room = Repo.preload(chat_room, :users)

    updated_users = Enum.reject(chat_room.users, fn u -> u.id == user.id end)

    chat_room
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_assoc(:users, updated_users)
    |> Repo.update()
  end

  @doc """
  Gets chat rooms that a user has joined.

  ## Examples

      iex> get_user_chat_rooms(user)
      [%ChatRoom{}, ...]

  """
  def get_user_chat_rooms(%User{} = user) do
    ChatRoom
    |> join(:inner, [cr], u in assoc(cr, :users))
    |> where([cr, u], u.id == ^user.id)
    |> Repo.all()
  end

  @doc """
  Adds a user to a chat room using ChatRoomMember.

  ## Examples

      iex> join_chat_room_as_member(chat_room_id, user_id)
      {:ok, %ChatRoomMember{}}

      iex> join_chat_room_as_member(chat_room_id, user_id)
      {:error, %Ecto.Changeset{}}

  """
  def join_chat_room_as_member(chat_room_id, user_id) do
    attrs = %{chat_room_id: chat_room_id, user_id: user_id}

    %ChatRoomMember{}
    |> ChatRoomMember.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Removes a user from a chat room using ChatRoomMember.

  ## Examples

      iex> leave_chat_room_as_member(chat_room_id, user_id)
      {:ok, %ChatRoomMember{}}

  """
  def leave_chat_room_as_member(chat_room_id, user_id) do
    case Repo.get_by(ChatRoomMember, chat_room_id: chat_room_id, user_id: user_id) do
      nil -> {:error, :not_found}
      member -> Repo.delete(member)
    end
  end

  @doc """
  Checks if a user is a member of a chat room.

  ## Examples

      iex> is_member?(chat_room_id, user_id)
      true

  """
  def is_member?(chat_room_id, user_id) do
    ChatRoomMember
    |> where([m], m.chat_room_id == ^chat_room_id and m.user_id == ^user_id)
    |> Repo.exists?()
  end
end
