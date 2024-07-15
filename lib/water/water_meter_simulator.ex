defmodule Water.WaterMeterSimulator do
  use GenServer
  alias Water.WaterManagement
  alias Water.Estates
  alias Water.Households

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{})
  end

  def init(state) do
    # Ensure we have some sample data
    create_sample_data()
    schedule_reading()
    {:ok, state}
  end

  def handle_info(:generate_reading, state) do
    generate_readings()
    schedule_reading()
    {:noreply, state}
  end

  defp schedule_reading do
    Process.send_after(self(), :generate_reading, :timer.seconds(10))
  end

  defp generate_readings do
    Households.list_households()
    |> Enum.each(fn household ->
      usage = %{
        household_id: household.id,
        meter_id: household.meter_id,
        usage: :rand.uniform() * 10,
        timestamp: DateTime.utc_now()
      }

      case WaterManagement.create_usage(usage) do
        {:ok, created_usage} ->
          Phoenix.PubSub.broadcast(Water.PubSub, "water_usage", {:usage_created, created_usage})
        {:error, changeset} ->
          IO.puts("Error creating usage: #{inspect(changeset)}")
      end
    end)
  end

  defp create_sample_data do
    # Create sample estates if they don't exist
    ["Estate A", "Estate B", "Estate C"]
    |> Enum.each(fn estate_name ->
      case Estates.get_estate_by_name(estate_name) do
        nil ->
          {:ok, estate} = Estates.create_estate(%{name: estate_name})
          create_sample_households(estate)
        estate ->
          create_sample_households(estate)
      end
    end)
  end

  defp create_sample_households(estate) do
    existing_households = Households.list_households_by_estate(estate.id)

    if Enum.empty?(existing_households) do
      1..5
      |> Enum.each(fn i ->
        Households.create_household(%{
          name: "Household #{i}",
          meter_id: "METER-#{estate.id}-#{i}",
          estate_id: estate.id
        })
      end)
    end
  end
end
