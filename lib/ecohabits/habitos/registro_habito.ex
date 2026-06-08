defmodule Ecohabits.Habitos.RegistroHabito do
  use Ecto.Schema
  import Ecto.Changeset

  schema "registros_habitos" do
    field :data_realizacao, :date
    belongs_to :habito, Ecohabits.Habitos.Habito
    field :usuario_id, :integer

    timestamps(inserted_at: :criado_em, updated_at: :atualizado_em, type: :utc_datetime)
  end

  @doc false
  def changeset(registro, attrs) do
    registro
    |> cast(attrs, [:data_realizacao, :habito_id, :usuario_id])
    |> validate_required([:data_realizacao, :habito_id, :usuario_id])
    |> foreign_key_constraint(:habito_id, name: :fk_registros_habito)
    |> foreign_key_constraint(:usuario_id, name: :fk_registros_usuario)
    |> unique_constraint([:habito_id, :usuario_id, :data_realizacao], name: :unique_checkin_diario, message: "Check-in já realizado hoje para este hábito.")
  end
end
