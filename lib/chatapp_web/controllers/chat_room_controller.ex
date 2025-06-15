defmodule ChatappWeb.ChatRoomController do
  use ChatappWeb, :controller

  alias Chatapp.ChatRooms
  alias Chatapp.ChatRoom

  def index(conn, _params) do
    chat_rooms = ChatRooms.list_chat_rooms()
    render(conn, :index, chat_rooms: chat_rooms, current_scope: conn.assigns[:current_scope])
  end

  def new(conn, _params) do
    changeset = ChatRooms.change_chat_room(%ChatRoom{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"chat_room" => chat_room_params}) do
    case ChatRooms.create_chat_room(chat_room_params) do
      {:ok, _chat_room} ->
        conn
        |> put_flash(:info, "채팅방이 성공적으로 생성되었습니다.")
        |> redirect(to: ~p"/chat_rooms")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end
end
