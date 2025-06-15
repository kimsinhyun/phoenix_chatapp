defmodule Chatapp.Repo.Migrations.CreateChatRoomMembers do
  use Ecto.Migration

  def change do
    create table(:chat_room_members) do
      add :user_id, references(:users, on_delete: :delete_all)
      add :chat_room_id, references(:chat_rooms, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:chat_room_members, [:user_id])
    create index(:chat_room_members, [:chat_room_id])
    create unique_index(:chat_room_members, [:user_id, :chat_room_id])
  end
end