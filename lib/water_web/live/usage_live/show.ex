defmodule WaterWeb.UsageLive.Show do
  use WaterWeb, :live_view

  alias Water.WaterManagement

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:usage, WaterManagement.get_usage!(id))}
  end

  defp page_title(:show), do: "Show Usage"
  defp page_title(:edit), do: "Edit Usage"
end
