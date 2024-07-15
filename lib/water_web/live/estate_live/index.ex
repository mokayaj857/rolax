defmodule WaterWeb.EstateLive.Index do
  use WaterWeb, :live_view

  alias Water.Estates
  alias Water.Households

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

    socket = assign(socket, selected_estate: estate, households: households)
    {:noreply, socket}
  end
end
