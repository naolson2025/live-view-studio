defmodule LiveViewStudioWeb.LightLive do
  use LiveViewStudioWeb, :live_view

  def mount(_params, _session, socket) do
    IO.inspect(self(), label: "MOUNT")
    socket = assign(socket, brightness: 10, color: "3000")
    {:ok, socket}
  end

  def render(assigns) do
    IO.inspect(self(), label: "RENDER")

    ~H"""
    <h1>Front Porch Light</h1>
    <div id="light">
      <div class="meter">
        <span style={"width: #{@brightness}%; background: #{temp_color(@color)}"}>
          <%= @brightness %>%
        </span>
      </div>
      <button phx-click="off">
        <img src="/images/light-off.svg" />
      </button>
      <button phx-click="down">
        <img src="/images/down.svg" />
      </button>
      <button phx-click="up">
        <img src="/images/up.svg" />
      </button>
      <button phx-click="on">
        <img src="/images/light-on.svg" />
      </button>
      <button phx-click="fire">
        <img src="/images/fire.svg" />
      </button>
      <form phx-change="slide">
        <input
          type="range"
          min="0"
          max="100"
          name="brightness"
          value={@brightness}
          phx-debounce="500"
        />
      </form>
      <form phx-change="radio">
        <div class="temps">
          <%= for temp <- ["3000", "4000", "5000"] do %>
            <div>
              <input type="radio" id={temp} name="temp" value={temp} checked={temp == @color} />
              <label for={temp}><%= temp %></label>
            </div>
          <% end %>
        </div>
      </form>
    </div>
    """
  end

  def handle_event("radio", params, socket) do
    temp = params["temp"]
    socket = assign(socket, color: temp)
    {:noreply, socket}
  end

  def handle_event("slide", params, socket) do
    brightness = params["brightness"]
    socket = assign(socket, brightness: brightness)
    {:noreply, socket}
  end

  def handle_event("on", _params, socket) do
    IO.inspect(self(), label: "HANDLE EVENT ON")
    {:noreply, assign(socket, brightness: 100)}
  end

  def handle_event("off", _params, socket) do
    {:noreply, assign(socket, brightness: 0)}
  end

  def handle_event("up", _params, socket) do
    # &() is an anonymous function
    # &1 is the first argument in this case brightness
    socket = update(socket, :brightness, &min(&1 + 10, 100))
    {:noreply, socket}
  end

  def handle_event("down", _params, socket) do
    socket = update(socket, :brightness, &max(&1 - 10, 0))
    {:noreply, socket}
  end

  def handle_event("fire", _params, socket) do
    # brightness should be a random number between 0 and 100
    brightness = Enum.random(0..100)
    {:noreply, assign(socket, brightness: brightness)}
  end

  defp temp_color("3000"), do: "#F1C40D"
  defp temp_color("4000"), do: "#FEFF66"
  defp temp_color("5000"), do: "#99CCFF"
end
