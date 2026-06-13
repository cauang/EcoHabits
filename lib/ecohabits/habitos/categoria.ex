defmodule Ecohabits.Habitos.Categoria do
  use Ecto.Schema
  import Ecto.Changeset

  schema "categorias" do
    field :nome, :string
    field :descricao, :string
  end

  @doc false 
  def changeset(categoria, attrs) do
    categoria
    |> cast(attrs, [:nome, :descricao])
    |> validate_required([:nome])
    |> unique_constraint(:nome)
  end
end
