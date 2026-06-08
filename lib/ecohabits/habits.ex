defmodule Ecohabits.Habits do
  alias Ecohabits.Repo
  alias Ecohabits.Habits.Habit

  def list_habitos do
    Repo.all(Habit)
  end

  def create_habito(attrs \\ %{}) do
    %Habit{}
    |> Habit.changeset(attrs)
    |> Repo.insert()
  end

  def change_habito(%Habit{} = habit, attrs \\ %{}) do
    Habit.changeset(habit, attrs)
  end
end
