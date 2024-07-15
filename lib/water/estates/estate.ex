defmodule Water.Estates.Estate do
  use Ecto.Schema
  import Ecto.Changeset

  schema "estates" do
    field :name, :string
    has_many :households, Water.Households.Household

    timestamps()
  end

  @doc false
  def changeset(estate, attrs) do
    estate
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
