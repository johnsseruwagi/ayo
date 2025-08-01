defmodule Ayo.KnowledgeBase.Category.Calculations.BudgetExceeded do
  use Ash.Resource.Calculation

  @impl true
  def load(_query, _opts, _context) do
    [:total_spent]
  end

  @impl true
  def calculate(records, _opts, _context) do
    Enum.map(records, &calculate_budget_exceeded/1)
  end

  defp calculate_budget_exceeded(category) do
    total_spent = Money.to_decimal(category.total_spent)
    budget = Money.to_decimal(category.monthly_budget)

    percentage = if Decimal.positive?(budget) do
      total_spent
      |> Decimal.div(budget)
      |> Decimal.mult(100)
      |> Decimal.to_float()

    else
      0.0
    end

    max(percentage, 100) > 100
  end
end