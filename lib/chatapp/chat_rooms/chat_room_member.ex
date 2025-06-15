defmodule Chatapp.ChatRooms.ChatRoomMember do
  use Ecto.Schema
  import Ecto.Changeset

  schema "chat_room_members" do
    belongs_to :user, Chatapp.Accounts.User
    belongs_to :chat_room, Chatapp.ChatRoom

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(chat_room_member, attrs) do
    chat_room_member
    |> cast(attrs, [:user_id, :chat_room_id])
    |> validate_required([:user_id, :chat_room_id])
    |> unique_constraint([:user_id, :chat_room_id])
  end
end
