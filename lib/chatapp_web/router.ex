defmodule ChatappWeb.Router do
  use ChatappWeb, :router

  import ChatappWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {ChatappWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_scope_for_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ChatappWeb do
    pipe_through :browser

    get "/", PageController, :home
    get "/users", PageController, :users
    get "/chat", PageController, :chat

    # ChatRoom 목록은 누구나 볼 수 있음
    get "/chat_rooms", ChatRoomController, :index
    # ChatRoom show 페이지를 LiveView로 변경
    live_session :chat_room_show, on_mount: [{ChatappWeb.UserAuth, :mount_current_scope}] do
      live "/chat_rooms/:id", ChatRoomLive.Show, :show
    end
    # ChatRoom 참여는 누구나 시도할 수 있음 (로그인 체크는 컨트롤러에서)
    post "/chat_rooms/:id/join", ChatRoomController, :join
    delete "/chat_rooms/:id/leave", ChatRoomController, :leave
  end

  scope "/api", ChatappWeb do
    pipe_through :api

    resources "/posts", PostController, except: [:new, :edit]
  end

  # Other scopes may use custom stacks.
  # scope "/api", ChatappWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:chatapp, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: ChatappWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", ChatappWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{ChatappWeb.UserAuth, :require_authenticated}] do
      live "/users/settings", UserLive.Settings, :edit
      live "/users/settings/confirm-email/:token", UserLive.Settings, :confirm_email
    end

    post "/users/update-password", UserSessionController, :update_password

    # ChatRoom 생성은 로그인이 필요함
    get "/chat_rooms/new", ChatRoomController, :new
    post "/chat_rooms", ChatRoomController, :create
  end

  scope "/", ChatappWeb do
    pipe_through [:browser]

    live_session :current_user,
      on_mount: [{ChatappWeb.UserAuth, :mount_current_scope}] do
      live "/users/register", UserLive.Registration, :new
      live "/users/log-in", UserLive.Login, :new
      live "/users/log-in/:token", UserLive.Confirmation, :new
    end

    post "/users/log-in", UserSessionController, :create
    delete "/users/log-out", UserSessionController, :delete
  end
end
