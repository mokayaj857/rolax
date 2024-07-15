defmodule Water.WaterManagement.Usage do
  use Ecto.Schema
  import Ecto.Changeset

  schema "usages" do
    field :timestamp, :utc_datetime
    field :usage, :float
    field :meter_id, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(usage, attrs) do
    usage
    |> cast(attrs, [:meter_id, :usage, :timestamp])
    |> validate_required([:meter_id, :usage, :timestamp])
  end
end
