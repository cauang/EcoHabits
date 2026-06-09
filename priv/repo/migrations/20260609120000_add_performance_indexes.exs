defmodule Ecohabits.Repo.Migrations.AddPerformanceIndexes do
  use Ecto.Migration

  def change do
    create index(:habitos, [:usuario_id])
    create index(:habitos, [:categoria_id])
    create index(:registros_habitos, [:habito_id])
    create index(:registros_habitos, [:usuario_id, :data_realizacao])
  end
end
