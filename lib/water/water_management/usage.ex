defmodule Water.WaterManagement.Usage do
  use Ecto.Schema
  import Ecto.Changeset

  schema "usages" do
    field :timestamp, :utc_datetime
    field :usage, :float
    field :meter_id, :string
    belongs_to :household, Water.Households.Household

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(usage, attrs) do
    usage
    |> cast(attrs, [:meter_id, :usage, :timestamp, :household_id])
    |> validate_required([:usage, :timestamp, :household_id])
    |> foreign_key_constraint(:household_id)
  end
end
