defmodule Ayo.KnowledgeBase.Category.Calculations.TotalSpent do
  use Ash.Resource.Calculation

  @impl true
  def load(_query, _opts, _context) do
    [expenses: [:amount]]
  end

  @impl true
  def calculate(records, _opts, _context) do
    Enum.map(records, &calculate_total_spent/1)
  end

  defp calculate_total_spent(category) do
    if length(category.expenses) > 0 do
      Enum.reduce(category.expenses, Money.new(0, category.currency), fn expense, acc ->
          Money.add(acc, expense.amount)
        end)
    else
      Money.new(0, category.currency)
    end
  end
end