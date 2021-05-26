defmodule NoughtsAndExsWeb.PageLive do
  use NoughtsAndExsWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    Phoenix.PubSub.subscribe(NoughtsAndExs.PubSub, "query")
    Phoenix.PubSub.subscribe(NoughtsAndExs.PubSub, "game")
    {:ok, assign(socket, query: "", results: %{}, values: %{})}
  end

  # @impl true
  # def handle_info(query, socket) do
  #   socket = assign(socket, query: query)
  #   {:noreply, socket}
  # end

  @impl true
  def handle_info({:choose, value}, socket) do
    current_values = socket.assigns.values
    new_current_values = Map.put(current_values, value, "X")
    socket = assign(socket, values: new_current_values)
    IO.inspect socket
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
