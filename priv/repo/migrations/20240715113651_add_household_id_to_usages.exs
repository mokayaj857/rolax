defmodule Water.Repo.Migrations.AddHouseholdIdToUsages do
  use Ecto.Migration

  def change do
    alter table(:usages) do
      add :household_id, references(:households, on_delete: :delete_all)
    end

    create index(:usages, [:household_id])
  end
end
