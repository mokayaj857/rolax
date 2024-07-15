defmodule Water.WaterManagement do
  @moduledoc """
  The WaterManagement context.
  """

  import Ecto.Query, warn: false
  alias Water.Repo

  alias Water.WaterManagement.Usage
  alias Water.Households.Household

  @doc """
  Returns the list of usages.

  ## Examples

      iex> list_usages()
      [%Usage{}, ...]

  """
  def list_usages do
    Repo.all(Usage)
  end

  @doc """
  Gets a single usage.

  Raises `Ecto.NoResultsError` if the Usage does not exist.

  ## Examples

      iex> get_usage!(123)
      %Usage{}

      iex> get_usage!(456)
      ** (Ecto.NoResultsError)

  """
  def get_usage!(id), do: Repo.get!(Usage, id)

  @doc """
  Creates a usage.

  ## Examples

      iex> create_usage(%{field: value})
      {:ok, %Usage{}}

      iex> create_usage(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_usage(attrs \\ %{}) do
    %Usage{}
    |> Usage.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a usage.

  ## Examples

      iex> update_usage(usage, %{field: new_value})
      {:ok, %Usage{}}

      iex> update_usage(usage, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_usage(%Usage{} = usage, attrs) do
    usage
    |> Usage.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a usage.

  ## Examples

      iex> delete_usage(usage)
      {:ok, %Usage{}}

      iex> delete_usage(usage)
      {:error, %Ecto.Changeset{}}

  """
  def delete_usage(%Usage{} = usage) do
    Repo.delete(usage)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking usage changes.

  ## Examples

      iex> change_usage(usage)
      %Ecto.Changeset{data: %Usage{}}

  """
  def change_usage(%Usage{} = usage, attrs \\ %{}) do
    Usage.changeset(usage, attrs)
  end

  @doc """
  Returns a list of usages for a specific estate.

  ## Examples

      iex> list_usages_by_estate(1)
      [%Usage{}, ...]

  """
  def list_usages_by_estate(estate_id) do
    Usage
    |> join(:inner, [u], h in assoc(u, :household))
    |> where([u, h], h.estate_id == ^estate_id)
    |> Repo.all()
  end

  @doc """
  Returns a list of usages for a specific household.

  ## Examples

      iex> list_usages_by_household(1)
      [%Usage{}, ...]

  """
  def list_usages_by_household(household_id) do
    Usage
    |> where([u], u.household_id == ^household_id)
    |> Repo.all()
  end

  @doc """
  Detects potential water leaks based on usage thresholds.

  ## Parameters

    - threshold: The usage threshold above which a leak is suspected (default: 50)

  ## Examples

      iex> detect_leaks()
      [%{household: %Household{}, estate: %Estate{}, total_usage: 75.5}, ...]

  """
  def detect_leaks(threshold \\ 50) do
    one_hour_ago = DateTime.utc_now() |> DateTime.add(-1, :hour)

    Usage
    |> where([u], u.timestamp >= ^one_hour_ago)
    |> group_by([u], u.household_id)
    |> having([u], sum(u.usage) > ^threshold)
    |> select([u], {u.household_id, sum(u.usage)})
    |> Repo.all()
    |> Enum.map(fn {household_id, total_usage} ->
      Repo.get(Household, household_id)
      |> Repo.preload(:estate)
    end)
    |> Enum.reject(&is_nil/1)
    |> Enum.map(fn household ->
      %{
        household: household,
        estate: household.estate,
        total_usage: Repo.one(from u in Usage,
          where: u.household_id == ^household.id and u.timestamp >= ^one_hour_ago,
          select: sum(u.usage))
      }
    end)
  end

  def list_recent_usages(opts \\ []) do
    limit = Keyword.get(opts, :limit, 10)
    estate_id = Keyword.get(opts, :estate_id)
    household_id = Keyword.get(opts, :household_id)

    Usage
    |> order_by([u], desc: u.timestamp)
    |> limit(^limit)
    |> filter_by_estate(estate_id)
    |> filter_by_household(household_id)
    |> preload([household: [estate: []]])
    |> Repo.all()
  end

  defp filter_by_estate(query, nil), do: query
  defp filter_by_estate(query, estate_id) do
    query
    |> join(:inner, [u], h in assoc(u, :household))
    |> where([u, h], h.estate_id == ^estate_id)
  end

  defp filter_by_household(query, nil), do: query
  defp filter_by_household(query, household_id) do
    query
    |> where([u], u.household_id == ^household_id)
  end
end
