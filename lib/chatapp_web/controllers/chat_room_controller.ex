defmodule ChatappWeb.ChatRoomController do
  use ChatappWeb, :controller

  alias Chatapp.ChatRooms
  alias Chatapp.ChatRooms.ChatRoom

  def index(conn, _params) do
    chat_rooms = ChatRooms.list_chat_rooms()
    current_scope = conn.assigns[:current_scope]

    # 현재 사용자가 참여한 채팅방 ID 목록을 가져옴
    joined_room_ids = if current_scope do
      current_scope.user
      |> ChatRooms.get_user_chat_rooms()
      |> Enum.map(& &1.id)
    else
      []
    end

    render(conn, :index,
      chat_rooms: chat_rooms,
      current_scope: current_scope,
      joined_room_ids: joined_room_ids
    )
  end

  def show(conn, %{"id" => id}) do
    chat_room = ChatRooms.get_chat_room_with_users!(id)
    current_scope = conn.assigns[:current_scope]

    # 현재 사용자가 참여한 채팅방인지 확인
    is_member = if current_scope do
      ChatRooms.is_user_member_of_chat_room?(current_scope.user.id, chat_room.id)
    else
      false
    end

    render(conn, :show, chat_room: chat_room, is_member: is_member, current_scope: current_scope)
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

  def join(conn, %{"id" => chat_room_id}) do
    current_scope = conn.assigns[:current_scope]

    if current_scope do
      case ChatRooms.join_chat_room_as_member(chat_room_id, current_scope.user.id) do
        {:ok, _member} ->
          conn
          |> put_flash(:info, "채팅방에 성공적으로 참여했습니다.")
          |> redirect(to: ~p"/chat_rooms/#{chat_room_id}")

        {:error, %Ecto.Changeset{errors: [user_id: {_, [constraint: :unique, constraint_name: _]}]}} ->
          conn
          |> put_flash(:info, "이미 참여한 채팅방입니다.")
          |> redirect(to: ~p"/chat_rooms/#{chat_room_id}")

        {:error, _changeset} ->
          conn
          |> put_flash(:error, "채팅방 참여에 실패했습니다.")
          |> redirect(to: ~p"/chat_rooms")
      end
    else
      conn
      |> put_flash(:error, "채팅방에 참여하려면 로그인이 필요합니다.")
      |> redirect(to: ~p"/users/log-in")
    end
  end
end
