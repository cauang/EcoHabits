defmodule Ecohabits.Habits.Habit do
  use Ecto.Schema
  import Ecto.Changeset

  @timestamps_opts [inserted_at: :criado_em, updated_at: :atualizado_em, type: :naive_datetime]

  schema "habitos" do
    field :nome, :string
    field :descricao, :string
    field :pontuacao, :integer, default: 0
    field :usuario_id, :integer
    field :categoria_id, :integer

    timestamps()
  end

  def changeset(habit, attrs) do
    habit
    |> cast(attrs, [:nome, :descricao, :pontuacao, :usuario_id, :categoria_id])
    |> validate_required([:nome, :pontuacao, :usuario_id, :categoria_id])
  end
end
