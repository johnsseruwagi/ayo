defmodule Ayo.KnowledgeBase.Category.Changes.MonthlyBudgetAmount do
  use Ash.Resource.Change

  @impl true
  def init(opts) do
    if is_atom(opts[:attribute]) do
      {:ok, opts}
    else
      {:error, "attribute must be an atom!"}
    end
  end

  @impl true
  def change(changeset, opts, _context) do
    case Ash.Changeset.fetch_change(changeset, opts[:attribute]) do
      {:ok, amount} when is_number(amount) or is_binary(amount) ->
        money = Money.new(amount, :USD)

        Ash.Changeset.force_change_attribute(changeset, opts[:attribute], money)

      :error ->
        changeset
    end
  end
end