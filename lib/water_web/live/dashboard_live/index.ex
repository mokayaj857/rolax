defmodule WaterWeb.DashboardLive.Index do

  use WaterWeb, :live_view

  alias Water.WaterManagement

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(Water.PubSub, "water_usage")
    end

    usages = WaterManagement.list_usages()

    socket = socket
      |> assign(:chart_data, prepare_chart_data(usages))

    {:ok, socket}
  end

  @impl true
  def handle_info({:usage_created, usage}, socket) do
    socket = update(socket, :chart_data, fn data ->
      [usage_to_chart_point(usage) | data]
      |> Enum.take(50)
      |> Enum.reverse()
    end)

    {:noreply, socket}
  end

  defp prepare_chart_data(usages) do
    usages
    |> Enum.map(&usage_to_chart_point/1)
    |> Enum.take(50)
    |> Enum.reverse()
  end

  defp usage_to_chart_point(usage) do
    %{
      timestamp: Calendar.strftime(usage.timestamp, "%Y-%m-%d %H:%M:%S"),
      usage: usage.usage
    }
  end
end
