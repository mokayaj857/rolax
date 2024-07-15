defmodule Water.Repo.Migrations.CreateHouseholds do
  use Ecto.Migration

  def change do
    create table(:households) do
      add :name, :string, null: false
      add :meter_id, :string, null: false
      add :estate_id, references(:estates, on_delete: :delete_all), null: false

      timestamps()
    end

    create unique_index(:households, [:meter_id])
    create index(:households, [:estate_id])
  end
end
