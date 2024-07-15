defmodule Water.Estates do
  import Ecto.Query, warn: false
  alias Water.Repo

  alias Water.Estates.Estate

  def list_estates do
    Repo.all(Estate)
  end

  def get_estate!(id), do: Repo.get!(Estate, id)

  def create_estate(attrs \\ %{}) do
    %Estate{}
    |> Estate.changeset(attrs)
    |> Repo.insert()
  end

  def update_estate(%Estate{} = estate, attrs) do
    estate
    |> Estate.changeset(attrs)
    |> Repo.update()
  end

  def delete_estate(%Estate{} = estate) do
    Repo.delete(estate)
  end

  def change_estate(%Estate{} = estate, attrs \\ %{}) do
    Estate.changeset(estate, attrs)
  end

  def get_estate_by_name(name) do
    Repo.get_by(Estate, name: name)
  end
end
