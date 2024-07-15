defmodule Water.WaterManagementTest do
  use Water.DataCase

  alias Water.WaterManagement

  describe "usages" do
    alias Water.WaterManagement.Usage

    import Water.WaterManagementFixtures

    @invalid_attrs %{timestamp: nil, usage: nil, meter_id: nil}

    test "list_usages/0 returns all usages" do
      usage = usage_fixture()
      assert WaterManagement.list_usages() == [usage]
    end

    test "get_usage!/1 returns the usage with given id" do
      usage = usage_fixture()
      assert WaterManagement.get_usage!(usage.id) == usage
    end

    test "create_usage/1 with valid data creates a usage" do
      valid_attrs = %{timestamp: ~U[2024-07-14 10:40:00Z], usage: 120.5, meter_id: "some meter_id"}

      assert {:ok, %Usage{} = usage} = WaterManagement.create_usage(valid_attrs)
      assert usage.timestamp == ~U[2024-07-14 10:40:00Z]
      assert usage.usage == 120.5
      assert usage.meter_id == "some meter_id"
    end

    test "create_usage/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = WaterManagement.create_usage(@invalid_attrs)
    end

    test "update_usage/2 with valid data updates the usage" do
      usage = usage_fixture()
      update_attrs = %{timestamp: ~U[2024-07-15 10:40:00Z], usage: 456.7, meter_id: "some updated meter_id"}

      assert {:ok, %Usage{} = usage} = WaterManagement.update_usage(usage, update_attrs)
      assert usage.timestamp == ~U[2024-07-15 10:40:00Z]
      assert usage.usage == 456.7
      assert usage.meter_id == "some updated meter_id"
    end

    test "update_usage/2 with invalid data returns error changeset" do
      usage = usage_fixture()
      assert {:error, %Ecto.Changeset{}} = WaterManagement.update_usage(usage, @invalid_attrs)
      assert usage == WaterManagement.get_usage!(usage.id)
    end

    test "delete_usage/1 deletes the usage" do
      usage = usage_fixture()
      assert {:ok, %Usage{}} = WaterManagement.delete_usage(usage)
      assert_raise Ecto.NoResultsError, fn -> WaterManagement.get_usage!(usage.id) end
    end

    test "change_usage/1 returns a usage changeset" do
      usage = usage_fixture()
      assert %Ecto.Changeset{} = WaterManagement.change_usage(usage)
    end
  end
end
