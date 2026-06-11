defmodule Ecohabits.Repo.Migrations.AddNameAndBioToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :nome, :string
      add :biografia, :text
    end
  end
end
