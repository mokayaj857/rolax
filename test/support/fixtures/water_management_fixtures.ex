defmodule Water.WaterManagementFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Water.WaterManagement` context.
  """

  @doc """
  Generate a usage.
  """
  def usage_fixture(attrs \\ %{}) do
    {:ok, usage} =
      attrs
      |> Enum.into(%{
        meter_id: "some meter_id",
        timestamp: ~U[2024-07-14 10:40:00Z],
        usage: 120.5
      })
      |> Water.WaterManagement.create_usage()

    usage
  end
end
