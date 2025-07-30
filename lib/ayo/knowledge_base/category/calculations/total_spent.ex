defmodule Ayo.KnowledgeBase.Category.Calculations.TotalSpent do
  use Ash.Resource.Calculation

  @impl true
  def load(_query, _opts, _context) do
    [expenses: [:amount]]
  end

  @impl true
  def calculate(records, _opts, _context) do
    Enum.map(records, &calculate_total_spent/1)
    |> Map.new()
  end

  defp calculate_total_spent(category) do
    if length(category.expenses) > 0 do
      total = Enum.reduce(category.expenses, Money.new(0, category.currency), fn expense, acc ->
          Money.add(acc, expense.amount)
        end)

      {category.id, total}

    else
      {category.id, Money.new(0, category.currency)}
    end
  end
end