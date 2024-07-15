defmodule WaterWeb.HouseholdLive.Show do
  use WaterWeb, :live_view

  alias Water.Households
  alias Water.WaterManagement

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    household = Households.get_household!(id) |> Water.Repo.preload(:estate)
    recent_usages = WaterManagement.list_recent_usages(household_id: household.id, limit: 20)

    if connected?(socket) do
      Phoenix.PubSub.subscribe(Water.PubSub, "household:#{household.id}")
    end

    graph_data = prepare_graph_data(recent_usages)

    socket = assign(socket,
      household: household,
      recent_usages: recent_usages,
      graph_data: graph_data
    )
    {:ok, socket}
  end

  @impl true
  def handle_info({:new_usage, usage}, socket) do
    updated_usages = [usage | socket.assigns.recent_usages] |> Enum.take(20)
    graph_data = prepare_graph_data(updated_usages)

    socket = assign(socket,
      recent_usages: updated_usages,
      graph_data: graph_data
    )

    {:noreply, socket}
  end

  defp prepare_graph_data(usages) do
    usages
    |> Enum.reverse()
    |> Enum.map_reduce({600, 400, nil, nil}, fn usage, {width, height, min_usage, max_usage} ->
      new_min = min(usage.usage, min_usage || usage.usage)
      new_max = max(usage.usage, max_usage || usage.usage)
      {usage, {width, height, new_min, new_max}}
    end)
    |> then(fn {usages, {width, height, min_usage, max_usage}} ->
      y_scale = (height - 40) / max((max_usage - min_usage), 0.1)
      x_scale = width / max((length(usages) - 1), 1)

      points = usages
      |> Enum.with_index()
      |> Enum.map(fn {usage, index} ->
        x = index * x_scale
        y = height - (usage.usage - min_usage) * y_scale - 20
        "#{x},#{y}"
      end)
      |> Enum.join(" ")

      %{
        points: points,
        width: width,
        height: height,
        min_usage: min_usage,
        max_usage: max_usage
      }
    end)
  end
end
