defmodule Ecohabits.Habitos.Habito do
  use Ecto.Schema
  import Ecto.Changeset

  schema "habitos" do
    field :nome, :string
    field :descricao, :string
    field :pontuacao, :integer

    belongs_to :categoria, Ecohabits.Habitos.Categoria
    belongs_to :usuario, Ecohabits.Accounts.User
    has_many :registros, Ecohabits.Habitos.RegistroHabito

    timestamps(inserted_at: :criado_em, updated_at: :atualizado_em, type: :utc_datetime)
  end

  @doc false
  def changeset(habito, attrs) do
    habito
    |> cast(attrs, [:nome, :descricao, :categoria_id, :pontuacao, :usuario_id])
    |> validate_required([:nome, :descricao, :categoria_id, :usuario_id])
    |> foreign_key_constraint(:usuario_id, name: :fk_habitos_usuario, message: "O usuário informado não existe no banco de dados. Cadastre um usuário primeiro.")
    |> foreign_key_constraint(:categoria_id, name: :fk_habitos_categoria, message: "Categoria inválida.")
  end
end
