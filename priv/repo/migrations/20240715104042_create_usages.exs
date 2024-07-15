defmodule Water.Repo.Migrations.CreateUsages do
  use Ecto.Migration

  def change do
    create table(:usages) do
      add :meter_id, :string
      add :usage, :float
      add :timestamp, :utc_datetime

      timestamps(type: :utc_datetime)
    end
  end
end
