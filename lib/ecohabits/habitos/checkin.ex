defmodule Ecohabits.Habitos.Checkin do
  use Ecto.Schema
  import Ecto.Changeset

  schema "checkins" do
    field :data, :date
    belongs_to :habito, Ecohabits.Habitos.Habito
    field :usuario_id, :integer

    timestamps(inserted_at: :criado_em, updated_at: :atualizado_em, type: :utc_datetime)
  end

  @doc false
  def changeset(checkin, attrs) do
    checkin
    |> cast(attrs, [:data, :habito_id, :usuario_id])
    |> validate_required([:data, :habito_id, :usuario_id])
    |> foreign_key_constraint(:habito_id, name: :fk_checkins_habito)
    |> foreign_key_constraint(:usuario_id, name: :fk_checkins_usuario)
    |> unique_constraint([:habito_id, :usuario_id, :data], name: :unique_checkin_diario, message: "Check-in já realizado hoje para este hábito.")
  end
end
