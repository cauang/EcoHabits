defmodule Ecohabits.Habits do
  @moduledoc """
  The Habits context.
  """

  import Ecto.Query, warn: false
  alias Ecohabits.Repo
  alias Ecohabits.Habits.Habit

  @doc """
  Returns the list of habitos.
  """
  def list_habitos do
    Repo.all(Habit)
  end

  @doc """
  Gets a single habito.
  """
  def get_habito!(id), do: Repo.get!(Habit, id)

  @doc """
  Creates a habito.
  """
  def create_habito(attrs \\ %{}) do
    %Habit{}
    |> Habit.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a habito.
  """
  def update_habito(%Habit{} = habit, attrs) do
    habit
    |> Habit.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a habito.
  """
  def delete_habito(%Habit{} = habit) do
    Repo.delete(habit)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking habito changes.
  """
  def change_habito(%Habit{} = habit, attrs \\ %{}) do
    Habit.changeset(habit, attrs)
  end
end
