defmodule WaterWeb.DashboardLive.Index do
  use WaterWeb, :live_view

  alias Water.WaterManagement
  alias Water.Estates
  alias Water.Households

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(Water.PubSub, "water_usage")
    end

    estates = Estates.list_estates()

    leaks =
      try do
        WaterManagement.detect_leaks()
      rescue
        e ->
          IO.puts("Error detecting leaks: #{inspect(e)}")
          []
      end

    socket = socket
      |> assign(:estates, estates)
      |> assign(:selected_estate, nil)
      |> assign(:households, [])
      |> assign(:selected_household, nil)
      |> assign(:chart_data, [])
      |> assign(:chart_params, %{})
      |> assign(:leaks, leaks)
      |> assign(:recent_usages, WaterManagement.list_recent_usages())

    {:ok, socket}
  end

  @impl true
  def handle_event("select-estate", %{"estate-id" => estate_id}, socket) do
    estate_id = String.to_integer(estate_id)
    estate = Enum.find(socket.assigns.estates, &(&1.id == estate_id))
    households = Households.list_households_by_estate(estate_id)
    usages = WaterManagement.list_usages_by_estate(estate_id)

    socket = socket
      |> assign(:selected_estate, estate)
      |> assign(:households, households)
      |> assign(:selected_household, nil)
      |> assign(:chart_data, prepare_chart_data(usages))
      |> assign(:chart_params, calculate_chart_params(usages))
      |> assign(:recent_usages, WaterManagement.list_recent_usages(estate_id: estate_id))

    {:noreply, socket}
  end

  @impl true
  def handle_event("select-household", %{"household-id" => household_id}, socket) do
    household_id = String.to_integer(household_id)
    household = Enum.find(socket.assigns.households, &(&1.id == household_id))
    usages = WaterManagement.list_usages_by_household(household_id)

    socket = socket
      |> assign(:selected_household, household)
      |> assign(:chart_data, prepare_chart_data(usages))
      |> assign(:chart_params, calculate_chart_params(usages))
      |> assign(:recent_usages, WaterManagement.list_recent_usages(household_id: household_id))

    {:noreply, socket}
  end

  @impl true
  def handle_info({:usage_created, usage}, socket) do
    socket = socket
      |> update(:chart_data, fn data ->
        [usage_to_chart_point(usage) | data]
        |> Enum.take(50)
        |> Enum.reverse()
      end)
      |> assign(:chart_params, calculate_chart_params(socket.assigns.chart_data))
      |> assign(:leaks, WaterManagement.detect_leaks())
      |> update(:recent_usages, fn usages -> [usage | usages] |> Enum.take(10) end)

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
    max_usage = Enum.max(usage_values ++ [0])
    min_usage = Enum.min(usage_values ++ [0])

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
    x_step = (width - 2 * padding) / max(1, data_count - 1)

    Enum.with_index(data)
    |> Enum.map(fn {%{usage: y}, index} ->
      x = padding + index * x_step
      y_range = max(0.1, max_y - min_y)  # Avoid division by zero
      y = height - padding - (y - min_y) / y_range * (height - 2 * padding)
      "#{x},#{y}"
    end)
    |> Enum.join(" ")
  end
end
