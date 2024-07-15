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
      |> assign(:chart_params, calculate_chart_params(usages))

    {:ok, socket}
  end

  @impl true
  def handle_info({:usage_created, usage}, socket) do
    new_data = [usage_to_chart_point(usage) | socket.assigns.chart_data]
      |> Enum.take(50)
      |> Enum.reverse()

    socket = socket
      |> assign(:chart_data, new_data)
      |> assign(:chart_params, calculate_chart_params(new_data))

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

  defp calculate_chart_params(data) do
    usage_values = Enum.map(data, & &1.usage)
    max_usage = Enum.max(usage_values)
    min_usage = Enum.min(usage_values)

    %{
      width: 600,
      height: 400,
      padding: 40,
      x_axis_labels: Enum.take_every(data, 5) |> Enum.map(& &1.timestamp),
      y_axis_max: max_usage,
      y_axis_min: min_usage,
      data_points: convert_to_svg_points(data, max_usage, min_usage, 600, 400, 40)
    }
  end

  defp convert_to_svg_points(data, max_y, min_y, width, height, padding) do
    data_count = length(data)
    x_step = (width - 2 * padding) / (data_count - 1)

    Enum.with_index(data)
    |> Enum.map(fn {%{usage: y}, index} ->
      x = padding + index * x_step
      y = height - padding - (y - min_y) / (max_y - min_y) * (height - 2 * padding)
      "#{x},#{y}"
    end)
    |> Enum.join(" ")
  end
end
