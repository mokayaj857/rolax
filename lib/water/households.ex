defmodule Water.Households do
  import Ecto.Query, warn: false
  alias Water.Repo

  alias Water.Households.Household

  def list_households do
    Repo.all(Household)
  end

  def list_households_by_estate(estate_id) do
    Household
    |> where([h], h.estate_id == ^estate_id)
    |> Repo.all()
  end

  def get_household!(id), do: Repo.get!(Household, id)

  def create_household(attrs \\ %{}) do
    %Household{}
    |> Household.changeset(attrs)
    |> Repo.insert()
  end

  def update_household(%Household{} = household, attrs) do
    household
    |> Household.changeset(attrs)
    |> Repo.update()
  end

  def delete_household(%Household{} = household) do
    Repo.delete(household)
  end

  def change_household(%Household{} = household, attrs \\ %{}) do
    Household.changeset(household, attrs)
  end

  def list_households_by_estate(estate_id) do
    Household
    |> where([h], h.estate_id == ^estate_id)
    |> Repo.all()
  end

end
