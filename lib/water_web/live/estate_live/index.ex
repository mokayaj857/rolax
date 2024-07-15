defmodule WaterWeb.EstateLive.Index do
  use WaterWeb, :live_view

  alias Water.Estates
  alias Water.Households
  alias Water.WaterManagement

  @impl true
  def mount(_params, _session, socket) do
    estates = Estates.list_estates()
    socket = assign(socket, estates: estates, selected_estate: nil, households: [])
    {:ok, socket}
  end

  @impl true
  def handle_event("select-estate", %{"estate-id" => estate_id}, socket) do
    estate_id = String.to_integer(estate_id)
    estate = Estates.get_estate!(estate_id)
    households = Households.list_households_by_estate(estate_id)
                 |> Enum.map(&add_household_metrics/1)

    socket = assign(socket, selected_estate: estate, households: households)
    {:noreply, socket}
  end

  defp add_household_metrics(household) do
    today = Date.utc_today()
    week_start = Date.add(today, -6)

    today_usage = WaterManagement.get_usage_for_period(household.id, today, today)
    week_usage = WaterManagement.get_usage_for_period(household.id, week_start, today)
    avg_daily_usage = week_usage / 7
    usage_trend = WaterManagement.get_daily_usage(household.id, week_start, today)
                  |> prepare_trend_data()
    leak_detected = WaterManagement.leak_detected?(household.id)

    household
    |> Map.put(:today_usage, today_usage)
    |> Map.put(:week_usage, week_usage)
    |> Map.put(:avg_daily_usage, avg_daily_usage)
    |> Map.put(:usage_trend, usage_trend)
    |> Map.put(:leak_detected, leak_detected)
  end

  defp prepare_trend_data(daily_usage) do
    max_usage = Enum.map(daily_usage, fn {_, usage} -> usage end) |> Enum.max(fn -> 0 end)

    daily_usage
    |> Enum.with_index()
    |> Enum.map(fn {{_, usage}, index} ->
      x = index * (200 / 6)  # 200 is SVG width, 6 is number of intervals in a week
      y = 50 - (usage / max_usage) * 45  # 50 is SVG height, leaving 5px margin
      "#{x},#{y}"
    end)
    |> Enum.join(" ")
  end
end
