defmodule Ecohabits.Habitos do
  @moduledoc """
  O contexto de Hábitos.
  Aqui residem as regras de negócio para a gestão de hábitos sustentáveis.
  Módulo B - Gestão de Hábitos
  """

  import Ecto.Query, warn: false
  alias Ecohabits.Repo
  alias Ecohabits.Habitos.Habito
  alias Ecohabits.Habitos.RegistroHabito
  alias Ecohabits.Habitos.PontuacaoSemanal
  alias Ecohabits.Habitos.Categoria

  def list_categorias do
    Repo.all(Categoria)
  end

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
    |> preload([:categoria, registros: ^registros_hoje_query])
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
    habito = get_habito!(habito_id)
    hoje = Date.utc_today()
    
    changeset = RegistroHabito.changeset(%RegistroHabito{}, %{
      habito_id: habito_id,
      usuario_id: usuario_id,
      data_realizacao: hoje
    })

    case Repo.insert(changeset) do
      {:ok, registro} ->
        atualizar_pontuacao_semanal(usuario_id, habito.pontuacao)
        {:ok, registro}
      {:error, erro} ->
        {:error, erro}
    end
  end

  def obter_pontuacao_semanal(usuario_id) do
    hoje = Date.utc_today()
    inicio_semana = Date.beginning_of_week(hoje)
    
    query = from p in PontuacaoSemanal,
      where: p.usuario_id == ^usuario_id and p.inicio_semana == ^inicio_semana,
      select: p.total_pontos
      
    Repo.one(query) || 0
  end

  defp atualizar_pontuacao_semanal(usuario_id, pontuacao) do
    hoje = Date.utc_today()
    inicio_semana = Date.beginning_of_week(hoje)
    fim_semana = Date.end_of_week(hoje)
    
    pontuacao_existente = Repo.get_by(PontuacaoSemanal, usuario_id: usuario_id, inicio_semana: inicio_semana)
    
    if pontuacao_existente do
      pontuacao_existente
      |> Ecto.Changeset.change(total_pontos: pontuacao_existente.total_pontos + pontuacao)
      |> Repo.update!()
    else
      %PontuacaoSemanal{}
      |> PontuacaoSemanal.changeset(%{
        usuario_id: usuario_id,
        inicio_semana: inicio_semana,
        fim_semana: fim_semana,
        total_pontos: pontuacao
      })
      |> Repo.insert!()
    end
  end
end
