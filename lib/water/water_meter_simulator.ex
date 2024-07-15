defmodule Water.WaterMeterSimulator do
  use GenServer
  alias Water.WaterManagement

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{})
  end

  def init(state) do
    schedule_reading()
    {:ok, state}
  end

  def handle_info(:generate_reading, state) do
    generate_reading()
    schedule_reading()
    {:noreply, state}
  end

  defp schedule_reading do
    Process.send_after(self(), :generate_reading, :timer.seconds(10))  # Generate a reading every 10 seconds
  end

  defp generate_reading do
    usage = %{
      meter_id: "METER-#{:rand.uniform(1000)}",
      usage: :rand.uniform() * 10,
      timestamp: DateTime.utc_now()
    }

    case WaterManagement.create_usage(usage) do
      {:ok, created_usage} ->
        Phoenix.PubSub.broadcast(Water.PubSub, "water_usage", {:usage_created, created_usage})
      {:error, changeset} ->
        IO.puts("Error creating usage: #{inspect(changeset)}")
    end
  end
end
