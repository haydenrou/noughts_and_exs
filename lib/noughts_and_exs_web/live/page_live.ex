defmodule NoughtsAndExsWeb.PageLive do
  use NoughtsAndExsWeb, :live_view

  def solutions() do
    Enum.map([1, 2, 3], fn row -> Enum.map([1, 2, 3], fn x -> {row, x} end) end) ++
      Enum.map([1, 2, 3], fn column -> Enum.map([1, 2, 3], fn x -> {x, column} end) end) ++
        [Enum.map([1, 2, 3], fn x -> {x, x} end)] ++
          [Enum.map([1, 2, 3], fn x -> {x, 4 - x} end)]
  end

  def stringify([{_x1, _y1}, {_x2, _y2}, {_x3, _y3}] = list) do
    Enum.map(list, fn {x, y} -> Integer.to_string(x) <> Integer.to_string(y) end)
  end

  @impl true
  def mount(_params, _session, socket) do
    Phoenix.PubSub.subscribe(NoughtsAndExs.PubSub, "query")
    Phoenix.PubSub.subscribe(NoughtsAndExs.PubSub, "game")
    Phoenix.PubSub.broadcast(NoughtsAndExs.PubSub, "joined", :joined)
    Phoenix.PubSub.subscribe(NoughtsAndExs.PubSub, "joined")

    {:ok, assign(socket, query: "", winner: nil, results: %{}, values: %{})}
  end

  @impl true
  def handle_info({:choose, value}, socket) do
    current_values = socket.assigns.values

    symbol =
      case Enum.count(current_values) |> rem(2) do
        0 -> "X"
        1 -> "O"
      end

    new_current_values = Map.put(current_values, value, symbol)
    socket = assign(socket, values: new_current_values)

    winning_symbol =
      Enum.map(solutions(), fn solution ->
        s = stringify(solution)
        values = Map.take(new_current_values, s) |> Map.values()

        cond do
          values == ["X", "X", "X"] -> "X"
          values == ["O", "O", "O"] -> "O"
          true -> nil
        end
      end)
      |> Enum.reduce(fn value, acc ->
        case value do
          "X" -> value
          "O" -> value
          _ -> acc
        end
      end)

    socket = assign(socket, winner: winning_symbol)
    {:noreply, socket}
  end

  @impl true
  def handle_info(:joined, socket) do
    Phoenix.PubSub.broadcast(NoughtsAndExs.PubSub, "game", {:populate, socket.assigns.values})
    {:noreply, socket}
  end

  @impl true
  def handle_info({:populate, values}, socket) do
    {:noreply, assign(socket, values: values)}
  end

  @impl true
  def handle_info(query, socket) do
    socket = assign(socket, query: query)
    {:noreply, socket}
  end

  @impl true
  def handle_event("suggest", %{"q" => query}, socket) do
    Phoenix.PubSub.broadcast(NoughtsAndExs.PubSub, "query", query)
    {:noreply, assign(socket, results: search(query), query: query)}
  end

  @impl true
  def handle_event("search", %{"q" => query}, socket) do
    case search(query) do
      %{^query => vsn} ->
        {:noreply, redirect(socket, external: "https://hexdocs.pm/#{query}/#{vsn}")}

      _ ->
        {:noreply,
         socket
         |> put_flash(:error, "No dependencies found matching \"#{query}\"")
         |> assign(results: %{}, query: query)}
    end
  end

  @impl true
  def handle_event("choose", %{"value" => value}, socket) do
    Phoenix.PubSub.broadcast(NoughtsAndExs.PubSub, "game", {:choose, value})
    {:noreply, socket}
  end

  defp search(query) do
    if not NoughtsAndExsWeb.Endpoint.config(:code_reloader) do
      raise "action disabled when not in development"
    end

    for {app, desc, vsn} <- Application.started_applications(),
        app = to_string(app),
        String.starts_with?(app, query) and not List.starts_with?(desc, ~c"ERTS"),
        into: %{},
        do: {app, vsn}
  end
end
