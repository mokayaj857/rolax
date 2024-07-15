defmodule WaterWeb.LandingLive.Index do
  use WaterWeb, :live_view

  alias Water.WaterManagement
  alias Water.Estates

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Process.send_after(self(), :update, 5000)

    socket =
      socket
      |> assign(page_title: "Water Usage Summary")
      |> assign_summary_data()

    {:ok, socket}
  end

  @impl true
  def handle_info(:update, socket) do
    Process.send_after(self(), :update, 5000)
    {:noreply, assign_summary_data(socket)}
  end

  defp assign_summary_data(socket) do
    end_date = Date.utc_today()
    start_date = Date.add(end_date, -30)

    total_usage = WaterManagement.get_total_usage(start_date, end_date)
    total_usage_data = WaterManagement.get_daily_total_usage(start_date, end_date)
    estate_usage_data = WaterManagement.get_daily_estate_usage(start_date, end_date)

    assign(socket,
      total_usage: total_usage,
      total_usage_data: prepare_graph_data(total_usage_data),
      estate_usage_data: prepare_estate_graph_data(estate_usage_data)
    )
  end

  defp prepare_graph_data(usage_data) do
    max_usage = Enum.map(usage_data, fn {_, usage} -> usage end) |> Enum.max(fn -> 0 end)

    usage_data
    |> Enum.map(fn {date, usage} ->
      %{
        date: Date.to_string(date),
        usage: usage,
        percentage: usage / max_usage * 100
      }
    end)
  end

  defp prepare_estate_graph_data(estate_usage_data) do
    estates = Estates.list_estates()
    dates = estate_usage_data |> Map.keys() |> Enum.sort()

    estates
    |> Enum.map(fn estate ->
      data = dates
      |> Enum.map(fn date ->
        usage = get_in(estate_usage_data, [date, estate.id]) || 0
        {date, usage}
      end)
      |> prepare_graph_data()

      %{
        estate_name: estate.name,
        data: data
      }
    end)
  end
end
