defmodule WaterWeb.UsageLive.Index do
  use WaterWeb, :live_view

  alias Water.WaterManagement
  alias Water.WaterManagement.Usage

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do:
      Phoenix.PubSub.subscribe(Water.PubSub, "water_usage")

    {:ok, assign(socket, :usages, list_usages())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    usage = WaterManagement.get_usage!(id)
    {:ok, _} = WaterManagement.delete_usage(usage)

    {:noreply, assign(socket, :usages, list_usages())}
  end

  @impl true
  def handle_info({:usage_created, usage}, socket) do
    {:noreply, update(socket, :usages, fn usages -> [usage | usages] end)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Usage")
    |> assign(:usage, WaterManagement.get_usage!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Usage")
    |> assign(:usage, %Usage{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Usages")
    |> assign(:usage, nil)
  end

  defp list_usages do
    WaterManagement.list_usages()
  end
end
