defmodule Ayo.KnowledgeBase.Category.Calculations.RecentExpenses do
  use Ash.Resource.Calculation

  @impl true
  def load(_query, _opts, _context) do
    [:expenses]
  end

  @impl true
  def calculate(records, _opts, _context) do
    Enum.map(records, &get_recent_expenses/1)
  end

  defp get_recent_expenses(category) do
    recent_expenses =
      if length(category.expenses) > 0 do
        category.expenses
        |> Enum.sort_by(& &1.inserted_at, {:desc, DateTime})
        |> Enum.take(5)

      else
        []
      end

      recent_expenses
  end
end