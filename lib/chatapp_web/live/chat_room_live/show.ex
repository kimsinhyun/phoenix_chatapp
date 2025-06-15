defmodule ChatappWeb.ChatRoomLive.Show do
  use ChatappWeb, :live_view
  alias Chatapp.ChatRooms
  alias Phoenix.PubSub

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    chat_room = ChatRooms.get_chat_room_with_users!(id)
    current_scope = socket.assigns[:current_scope]

    is_member = if current_scope do
      ChatRooms.is_user_member_of_chat_room?(current_scope.user.id, chat_room.id)
    else
      false
    end

    # 온라인 사용자 목록 초기화
    online_users = get_online_users(id)

    # 채팅방 토픽 구독 및 온라인 상태 등록
    if connected?(socket) do
      PubSub.subscribe(Chatapp.PubSub, "chat_room:#{id}")
      PubSub.subscribe(Chatapp.PubSub, "chat_room:#{id}:presence")

      # 현재 사용자가 멤버라면 온라인 상태로 등록
      if is_member && current_scope do
        # 현재 사용자를 온라인 목록에 추가
        updated_online = MapSet.put(online_users, current_scope.user.id)

        # 온라인 사용자 목록 저장
        :ets.insert(:online_users, {"chat_room:#{id}", updated_online})

        # 다른 사용자들에게 알림
        PubSub.broadcast(Chatapp.PubSub, "chat_room:#{id}:presence",
          {:user_joined, current_scope.user.id})

        # 업데이트된 온라인 목록 사용
        online_users = updated_online
      end
    end

    # 디버깅을 위한 로그 추가
    if current_scope && is_member do
      IO.puts("사용자 #{current_scope.user.id}가 채팅방 #{id}에 접속했습니다.")
      IO.puts("현재 온라인 사용자: #{inspect(MapSet.to_list(online_users))}")
    end

    {:ok, assign(socket,
      chat_room: chat_room,
      is_member: is_member,
      current_scope: current_scope,
      online_users: online_users
    )}
  end

  @impl true
  def terminate(_reason, socket) do
    # 사용자가 페이지를 떠날 때 온라인 상태에서 제거
    if socket.assigns[:current_scope] && socket.assigns[:is_member] do
      chat_room_id = socket.assigns.chat_room.id
      user_id = socket.assigns.current_scope.user.id

      current_online = get_online_users(chat_room_id)
      updated_online = MapSet.delete(current_online, user_id)

      :ets.insert(:online_users, {"chat_room:#{chat_room_id}", updated_online})

      # 다른 사용자들에게 알림
      PubSub.broadcast(Chatapp.PubSub, "chat_room:#{chat_room_id}:presence",
        {:user_left, user_id})
    end

    :ok
  end

  @impl true
  def handle_info({:user_joined, user_id}, socket) do
    online_users = MapSet.put(socket.assigns.online_users, user_id)
    {:noreply, assign(socket, online_users: online_users)}
  end

  def handle_info({:user_left, user_id}, socket) do
    online_users = MapSet.delete(socket.assigns.online_users, user_id)
    {:noreply, assign(socket, online_users: online_users)}
  end

  def handle_info({:member_joined, _member}, socket) do
    # 새 멤버가 추가되면 채팅방 정보 다시 로드
    chat_room = ChatRooms.get_chat_room_with_users!(socket.assigns.chat_room.id)
    {:noreply, assign(socket, chat_room: chat_room)}
  end

  @impl true
  def handle_event("send_message", %{"message" => message_text}, socket) do
    # 메시지 전송 로직 (나중에 구현)
    if socket.assigns.is_member && String.trim(message_text) != "" do
      # 여기서 메시지를 저장하고 브로드캐스트
      IO.puts("메시지 전송: #{message_text}")
    end

    {:noreply, socket}
  end

  # 온라인 사용자 목록을 가져오는 헬퍼 함수
  defp get_online_users(chat_room_id) do
    case :ets.lookup(:online_users, "chat_room:#{chat_room_id}") do
      [{"chat_room:" <> _, online_users}] -> online_users
      [] -> MapSet.new()
    end
  end

  # 사용자가 온라인인지 확인하는 헬퍼 함수
  defp user_online?(online_users, user_id) do
    MapSet.member?(online_users, user_id)
  end
end
