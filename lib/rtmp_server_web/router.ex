defmodule RtmpServerWeb.Router do
  use RtmpServerWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/webrtc", RtmpServerWeb do
    pipe_through :api
    get "/:base32_key", WebRTCController, :connect
  end

end
