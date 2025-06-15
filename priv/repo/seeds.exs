# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Chatapp.Repo.insert!(%Chatapp.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Chatapp.Repo
alias Chatapp.ChatRoom

# 테스트용 채팅방 생성
chat_rooms = [
  %{
    name: "일반 대화",
    description: "자유롭게 대화할 수 있는 공간입니다."
  },
  %{
    name: "개발 이야기",
    description: "프로그래밍과 개발에 관한 이야기를 나누는 곳입니다."
  },
  %{
    name: "취미 생활",
    description: "다양한 취미와 관심사에 대해 이야기해보세요."
  },
  %{
    name: "질문과 답변",
    description: "궁금한 것이 있으면 언제든지 질문해주세요."
  },
  %{
    name: "Phoenix 학습",
    description: "Phoenix Framework를 함께 공부하는 공간입니다."
  }
]

Enum.each(chat_rooms, fn room_attrs ->
  case Repo.get_by(ChatRoom, name: room_attrs.name) do
    nil ->
      %ChatRoom{}
      |> ChatRoom.changeset(room_attrs)
      |> Repo.insert!()
      |> IO.inspect(label: "Created chat room")

    existing_room ->
      IO.puts("Chat room '#{existing_room.name}' already exists")
  end
end)
