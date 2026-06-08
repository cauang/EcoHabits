defmodule Ecohabits.Habitos do
  @moduledoc """
  O contexto de Hábitos.
  Aqui residem as regras de negócio para a gestão de hábitos sustentáveis.
  """

  import Ecto.Query, warn: false
  alias Ecohabits.Repo
  alias Ecohabits.Habitos.Habito
  alias Ecohabits.Habitos.RegistroHabito

  def list_habitos(criteria \\ %{}) do
    query = Habito

    query =
      if categoria_id = criteria[:categoria_id] do
        if categoria_id == "all", do: query, else: where(query, [h], h.categoria_id == ^categoria_id)
      else
        query
      end

    query =
      if busca = criteria[:busca] do
        busca_like = "%#{busca}%"
        where(query, [h], ilike(h.nome, ^busca_like) or ilike(h.descricao, ^busca_like))
      else
        query
      end

    usuario_id = criteria[:usuario_id] || 1
    hoje = Date.utc_today()
    registros_hoje_query = from r in RegistroHabito, where: r.usuario_id == ^usuario_id and r.data_realizacao == ^hoje

    query
    |> preload(registros: ^registros_hoje_query)
    |> order_by([h], desc: h.id)
    |> Repo.all()
  end

  def change_habito(%Habito{} = habito, attrs \\ %{}) do
    Habito.changeset(habito, attrs)
  end

  def create_habito(attrs \\ %{}) do
    %Habito{}
    |> Habito.changeset(attrs)
    |> Repo.insert()
  end

  def get_habito!(id), do: Repo.get!(Habito, id)

  def update_habito(%Habito{} = habito, attrs) do
    habito
    |> Habito.changeset(attrs)
    |> Repo.update()
  end

  def delete_habito(%Habito{} = habito) do
    Repo.delete(habito)
  end

  def fazer_checkin(habito_id, usuario_id) do
    %RegistroHabito{}
    |> RegistroHabito.changeset(%{
      habito_id: habito_id,
      usuario_id: usuario_id,
      data_realizacao: Date.utc_today()
    })
    |> Repo.insert()
  end
end
