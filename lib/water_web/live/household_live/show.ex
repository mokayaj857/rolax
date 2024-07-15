defmodule WaterWeb.HouseholdLive.Show do
  use WaterWeb, :live_view

  alias Water.Households
  alias Water.WaterManagement

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    household = Households.get_household!(id) |> Water.Repo.preload(:estate)
    recent_usages = WaterManagement.list_recent_usages(household_id: household.id, limit: 10)

    socket = assign(socket, household: household, recent_usages: recent_usages)
    {:ok, socket}
  end
end
