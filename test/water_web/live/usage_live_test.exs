defmodule WaterWeb.UsageLiveTest do
  use WaterWeb.ConnCase

  import Phoenix.LiveViewTest
  import Water.WaterManagementFixtures

  @create_attrs %{timestamp: "2024-07-14T10:40:00Z", usage: 120.5, meter_id: "some meter_id"}
  @update_attrs %{timestamp: "2024-07-15T10:40:00Z", usage: 456.7, meter_id: "some updated meter_id"}
  @invalid_attrs %{timestamp: nil, usage: nil, meter_id: nil}

  defp create_usage(_) do
    usage = usage_fixture()
    %{usage: usage}
  end

  describe "Index" do
    setup [:create_usage]

    test "lists all usages", %{conn: conn, usage: usage} do
      {:ok, _index_live, html} = live(conn, ~p"/usages")

      assert html =~ "Listing Usages"
      assert html =~ usage.meter_id
    end

    test "saves new usage", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/usages")

      assert index_live |> element("a", "New Usage") |> render_click() =~
               "New Usage"

      assert_patch(index_live, ~p"/usages/new")

      assert index_live
             |> form("#usage-form", usage: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#usage-form", usage: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/usages")

      html = render(index_live)
      assert html =~ "Usage created successfully"
      assert html =~ "some meter_id"
    end

    test "updates usage in listing", %{conn: conn, usage: usage} do
      {:ok, index_live, _html} = live(conn, ~p"/usages")

      assert index_live |> element("#usages-#{usage.id} a", "Edit") |> render_click() =~
               "Edit Usage"

      assert_patch(index_live, ~p"/usages/#{usage}/edit")

      assert index_live
             |> form("#usage-form", usage: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#usage-form", usage: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/usages")

      html = render(index_live)
      assert html =~ "Usage updated successfully"
      assert html =~ "some updated meter_id"
    end

    test "deletes usage in listing", %{conn: conn, usage: usage} do
      {:ok, index_live, _html} = live(conn, ~p"/usages")

      assert index_live |> element("#usages-#{usage.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#usages-#{usage.id}")
    end
  end

  describe "Show" do
    setup [:create_usage]

    test "displays usage", %{conn: conn, usage: usage} do
      {:ok, _show_live, html} = live(conn, ~p"/usages/#{usage}")

      assert html =~ "Show Usage"
      assert html =~ usage.meter_id
    end

    test "updates usage within modal", %{conn: conn, usage: usage} do
      {:ok, show_live, _html} = live(conn, ~p"/usages/#{usage}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Usage"

      assert_patch(show_live, ~p"/usages/#{usage}/show/edit")

      assert show_live
             |> form("#usage-form", usage: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#usage-form", usage: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/usages/#{usage}")

      html = render(show_live)
      assert html =~ "Usage updated successfully"
      assert html =~ "some updated meter_id"
    end
  end
end
