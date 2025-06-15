defmodule Chatapp.ChatRooms.ChatRoom do
  use Ecto.Schema
  import Ecto.Changeset

  schema "chat_rooms" do
    field :name, :string
    field :description, :string

    many_to_many :users, Chatapp.Accounts.User,
      join_through: Chatapp.ChatRooms.ChatRoomMember,
      on_replace: :delete

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(chat_room, attrs) do
    chat_room
    |> cast(attrs, [:name, :description])
    |> validate_required([:name])
    |> validate_length(:name, min: 1, max: 100)
    |> validate_length(:description, max: 500)
    |> unique_constraint(:name)
  end
end
