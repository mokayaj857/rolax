defmodule Water.Households.Household do
  use Ecto.Schema
  import Ecto.Changeset

  schema "households" do
    field :name, :string
    field :meter_id, :string
    belongs_to :estate, Water.Estates.Estate
    has_many :usages, Water.WaterManagement.Usage

    timestamps()
  end

  @doc false
  def changeset(household, attrs) do
    household
    |> cast(attrs, [:name, :meter_id, :estate_id])
    |> validate_required([:name, :meter_id, :estate_id])
    |> unique_constraint(:meter_id)
  end
end
