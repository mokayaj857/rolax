defmodule WaterWeb.UsageLive.FormComponent do
  use WaterWeb, :live_component

  alias Water.WaterManagement

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage usage records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="usage-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:meter_id]} type="text" label="Meter" />
        <.input field={@form[:usage]} type="number" label="Usage" step="any" />
        <.input field={@form[:timestamp]} type="datetime-local" label="Timestamp" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Usage</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{usage: usage} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(WaterManagement.change_usage(usage))
     end)}
  end

  @impl true
  def handle_event("validate", %{"usage" => usage_params}, socket) do
    changeset = WaterManagement.change_usage(socket.assigns.usage, usage_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"usage" => usage_params}, socket) do
    save_usage(socket, socket.assigns.action, usage_params)
  end

  defp save_usage(socket, :edit, usage_params) do
    case WaterManagement.update_usage(socket.assigns.usage, usage_params) do
      {:ok, usage} ->
        notify_parent({:saved, usage})

        {:noreply,
         socket
         |> put_flash(:info, "Usage updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_usage(socket, :new, usage_params) do
    case WaterManagement.create_usage(usage_params) do
      {:ok, usage} ->
        notify_parent({:saved, usage})

        {:noreply,
         socket
         |> put_flash(:info, "Usage created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
