defmodule WaterWeb.UsageLive.Index do
  use WaterWeb, :live_view

  alias Water.WaterManagement
  alias Water.WaterManagement.Usage

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :usages, WaterManagement.list_usages())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
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

  @impl true
  def handle_info({WaterWeb.UsageLive.FormComponent, {:saved, usage}}, socket) do
    {:noreply, stream_insert(socket, :usages, usage)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    usage = WaterManagement.get_usage!(id)
    {:ok, _} = WaterManagement.delete_usage(usage)

    {:noreply, stream_delete(socket, :usages, usage)}
  end
end
