defmodule Ecohabits.Habitos.PontuacaoSemanal do
  use Ecto.Schema
  import Ecto.Changeset

  schema "pontuacoes_semanais" do
    field :usuario_id, :integer
    field :inicio_semana, :date
    field :fim_semana, :date
    field :total_pontos, :integer, default: 0

    timestamps(type: :utc_datetime, inserted_at: :criado_em, updated_at: false)
  end

  def changeset(pontuacao, attrs) do
    pontuacao
    |> cast(attrs, [:usuario_id, :inicio_semana, :fim_semana, :total_pontos])
    |> validate_required([:usuario_id, :inicio_semana, :fim_semana])
  end
end
