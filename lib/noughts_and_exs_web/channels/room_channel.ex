defmodule NoughtsAndExsWeb.RoomChannel do
  use Phoenix.Channel

  def join("room:1", message, socket) do
    IO.inspect(message)

    {:ok, socket}
  end
end
