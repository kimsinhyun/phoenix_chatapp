defmodule ChatappWeb.PageController do
  use ChatappWeb, :controller

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :home, layout: false, current_scope: conn.assigns[:current_scope])
  end

  def users(conn, _params) do
    # The users page is often custom made,
    # so skip the default app layout.

    users = [
      %{id: 1, name: "John Doe"},
      %{id: 2, name: "Jane Smith"},
      %{id: 3, name: "Alice Johnson"}
    ]

    render(conn, :users, users: users, layout: false)
  end

  def chat(conn, _params) do
    render(conn, :chat)
  end
end
