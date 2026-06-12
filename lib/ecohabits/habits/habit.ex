defmodule Ecohabits.Habits.Habit do
  use Ecto.Schema
  import Ecto.Changeset

  @timestamps_opts [
    inserted_at: :criado_em,
    updated_at: :atualizado_em
  ]

  schema "habitos" do
    field :nome, :string
    field :descricao, :string
    field :pontuacao, :integer, default: 0
    field :categoria_id, :integer
    field :usuario_id, :integer

    timestamps()
  end

  @doc false
  def changeset(habit, attrs) do
    habit
    |> cast(attrs, [:nome, :descricao, :pontuacao, :categoria_id, :usuario_id])
    |> validate_required([:nome, :pontuacao, :categoria_id, :usuario_id])
    |> validate_number(:pontuacao, greater_than_or_equal_to: 0)
  end
end
