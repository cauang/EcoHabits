defmodule Ecohabits.Habitos do

  import Ecto.Query, warn: false
  require Logger
  alias Ecohabits.Repo
  alias Ecohabits.Habitos.Habito
  alias Ecohabits.Habitos.RegistroHabito
  alias Ecohabits.Habitos.PontuacaoSemanal
  alias Ecohabits.Habitos.Categoria
  alias Ecohabits.Accounts.User

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

  def list_habitos_checados_hoje(usuario_id) do
    hoje = Date.utc_today()

    from(r in RegistroHabito,
      where: r.usuario_id == ^usuario_id and r.data_realizacao == ^hoje,
      select: r.habito_id
    )
    |> Repo.all()
    |> MapSet.new()
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

  def dashboard_stats(usuario_id) do
    %{
      weekly_points: obter_pontuacao_semanal(usuario_id),
      total_points: total_points(usuario_id),
      current_streak: current_streak(usuario_id),
      monthly_checkins: count_monthly_checkins(usuario_id),
      active_days: count_active_days(usuario_id),
      weekly_data: weekly_points_data(usuario_id),
      monthly_data: monthly_points_data(usuario_id),
      recent_checkins: list_checkins_history(usuario_id, 5)
    }
  end

  def list_checkins_history(usuario_id, limit \\ 5) do
    query =
      from r in RegistroHabito,
        where: r.usuario_id == ^usuario_id,
        order_by: [desc: r.criado_em],
        limit: ^limit,
        preload: [habito: [:categoria]]

    Repo.all(query)
    |> Enum.map(fn registro ->
      %{
        id: registro.id,
        habit: registro.habito.nome,
        category: registro.habito.categoria.nome,
        points: registro.habito.pontuacao,
        date: registro.data_realizacao,
        streak: 1,
        created_at: registro.criado_em
      }
    end)
  end

  def list_recent_feed(limit \\ 8) do
    query =
      from r in RegistroHabito,
        join: h in Habito,
        on: r.habito_id == h.id,
        join: c in Categoria,
        on: h.categoria_id == c.id,
        join: u in User,
        on: r.usuario_id == u.id,
        order_by: [desc: r.criado_em],
        limit: ^limit,
        select: %{
          id: r.id,
          user_name: u.name,
          habit: h.nome,
          category: c.nome,
          points: h.pontuacao,
          created_at: r.criado_em
        }

    Repo.all(query)
    |> Enum.map(&build_feed_item/1)
  end

  def top_contributors(limit \\ 5) do
    query =
      from r in RegistroHabito,
        join: u in User,
        on: r.usuario_id == u.id,
        join: h in Habito,
        on: r.habito_id == h.id,
        group_by: [u.id, u.name],
        order_by: [desc: sum(h.pontuacao)],
        limit: ^limit,
        select: %{
          id: u.id,
          name: u.name,
          points: sum(h.pontuacao)
        }

    Repo.all(query)    |> Enum.with_index(1)
    |> Enum.map(fn {contributor, rank} -> Map.put(contributor, :rank, rank) end)  end


  def community_stats do
    today = Date.utc_today()

    total_points =
      from(r in RegistroHabito,
        join: h in Habito,
        on: r.habito_id == h.id,
        select: coalesce(sum(h.pontuacao), 0)
      )
      |> Repo.one()

    checkins_today =
      from(r in RegistroHabito,
        where: r.data_realizacao == ^today,
        select: count(r.id)
      )
      |> Repo.one()

    %{
      members: Repo.aggregate(User, :count, :id),
      checkins_today: checkins_today,
      total_points: total_points || 0,
      co2_reduced_today: Float.round((checkins_today || 0) * 3.4, 1)
    }
  end

  def total_points(usuario_id) do
    from(r in RegistroHabito,
      join: h in Habito,
      on: r.habito_id == h.id,
      where: r.usuario_id == ^usuario_id,
      select: coalesce(sum(h.pontuacao), 0)
    )
    |> Repo.one()
  end

  def count_monthly_checkins(usuario_id) do
    start_of_month = Date.beginning_of_month(Date.utc_today())

    from(r in RegistroHabito,
      where: r.usuario_id == ^usuario_id and r.data_realizacao >= ^start_of_month,
      select: count(r.id)
    )
    |> Repo.one()
  end

  def count_active_days(usuario_id) do
    start_of_month = Date.beginning_of_month(Date.utc_today())

    from(r in RegistroHabito,
      where: r.usuario_id == ^usuario_id and r.data_realizacao >= ^start_of_month,
      select: count(r.data_realizacao, :distinct)
    )
    |> Repo.one()
  end

  def current_streak(usuario_id) do
    dates =
      from(r in RegistroHabito,
        where: r.usuario_id == ^usuario_id,
        distinct: r.data_realizacao,
        order_by: [desc: r.data_realizacao],
        select: r.data_realizacao
      )
      |> Repo.all()

    count_consecutive(dates, Date.utc_today(), 0)
  end

  def weekly_points_data(usuario_id) do
    today = Date.utc_today()
    days = for offset <- 6..0//-1, do: Date.add(today, -offset)

    raw_points =
      from(r in RegistroHabito,
        join: h in Habito,
        on: r.habito_id == h.id,
        where: r.usuario_id == ^usuario_id and r.data_realizacao in ^days,
        group_by: r.data_realizacao,
        select: {r.data_realizacao, sum(h.pontuacao), count(r.id)}
      )
      |> Repo.all()
      |> Map.new(fn {date, points, habits} -> {date, %{points: points || 0, habits: habits}} end)

    Enum.map(days, fn date ->
      values = Map.get(raw_points, date, %{points: 0, habits: 0})

      %{
        day: format_weekday(date),
        points: values.points,
        habits: values.habits
      }
    end)
  end

  def monthly_points_data(usuario_id) do
    today = Date.utc_today()
    start_of_week = Date.beginning_of_week(today)

    for week_index <- 0..3 do
      week_start = Date.add(start_of_week, -7 * (3 - week_index))
      week_end = Date.add(week_start, 6)

      points = total_points_in_range(usuario_id, week_start, week_end)

      %{
        week: "Sem #{week_index + 1}",
        points: points
      }
    end
  end

  defp total_points_in_range(usuario_id, start_date, end_date) do
    from(r in RegistroHabito,
      join: h in Habito,
      on: r.habito_id == h.id,
      where: r.usuario_id == ^usuario_id and r.data_realizacao >= ^start_date and r.data_realizacao <= ^end_date,
      select: coalesce(sum(h.pontuacao), 0)
    )
    |> Repo.one()
  end

  defp build_feed_item(%{user_name: user_name, habit: habit, category: category, points: points, created_at: created_at}) do
    %{
      user: user_name,
      avatar: initials(user_name),
      habit: habit,
      category: category,
      points: points,
      time: format_relative_time(created_at),
      streak: streak_badge(category),
      color: category_color(category)
    }
  end

  defp initials(name) when is_binary(name) do
    name
    |> String.split()
    |> Enum.map(&String.first/1)
    |> Enum.take(2)
    |> Enum.join("")
  end

  defp format_relative_time(%DateTime{} = datetime) do
    diff = DateTime.diff(DateTime.utc_now(), datetime, :minute)

    cond do
      diff < 2 -> "Há poucos segundos"
      diff < 60 -> "Há #{diff} minutos"
      diff < 120 -> "Há 1 hora"
      diff < 1440 -> "Hoje, #{format_hour(datetime)}"
      diff < 2880 -> "Ontem, #{format_hour(datetime)}"
      true -> "Há #{div(diff, 1440)} dias"
    end
  end

  defp format_hour(datetime) do
    datetime
    |> DateTime.to_time()
    |> Time.to_string()
    |> String.slice(0, 5)
  end

  defp streak_badge(_category), do: Enum.random(3..15)

  defp category_color(category) do
    case category do
      "Resíduos" -> "emerald"
      "Transporte" -> "blue"
      "Alimentação" -> "orange"
      "Água" -> "cyan"
      "Energia" -> "yellow"
      _ -> "emerald"
    end
  end

  defp format_weekday(date) do
    case Date.day_of_week(date) do
      1 -> "Seg"
      2 -> "Ter"
      3 -> "Qua"
      4 -> "Qui"
      5 -> "Sex"
      6 -> "Sáb"
      7 -> "Dom"
    end
  end

  defp count_consecutive([], _expected_date, count), do: count

  defp count_consecutive([date | rest], expected_date, count) do
    if Date.compare(date, expected_date) == :eq do
      count_consecutive(rest, Date.add(expected_date, -1), count + 1)
    else
      count
    end
  end

  def fazer_checkin(habito_id, usuario_id) do
    Logger.debug("[Habitos] fazer_checkin called for habito_id=#{inspect(habito_id)} usuario_id=#{inspect(usuario_id)}")
    habito = get_habito!(habito_id)
    hoje = Date.utc_today()

    changeset = RegistroHabito.changeset(%RegistroHabito{}, %{
      habito_id: habito_id,
      usuario_id: usuario_id,
      data_realizacao: hoje
    })

    case Repo.insert(changeset) do
      {:ok, registro} ->
        Logger.debug("[Habitos] insert ok for registro id=#{registro.id}")
        atualizar_pontuacao_semanal(usuario_id, habito.pontuacao)
        {:ok, registro}

      {:error, erro} ->
        Logger.debug("[Habitos] insert error: #{inspect(erro.errors || erro)}")
        {:error, erro}
    end
  end

  def obter_pontuacao_semanal(usuario_id) do
    hoje = Date.utc_today()
    inicio_semana = Date.beginning_of_week(hoje)
    fim_semana = Date.end_of_week(hoje)

    from(r in RegistroHabito,
      join: h in Habito,
      on: r.habito_id == h.id,
      where: r.usuario_id == ^usuario_id and r.data_realizacao >= ^inicio_semana and r.data_realizacao <= ^fim_semana,
      select: coalesce(sum(h.pontuacao), 0)
    )
    |> Repo.one()
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
