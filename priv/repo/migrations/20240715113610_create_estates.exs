defmodule Water.Repo.Migrations.CreateEstates do
  use Ecto.Migration

  def change do
    create table(:estates) do
      add :name, :string, null: false

      timestamps()
    end

    create unique_index(:estates, [:name])
  end
end
