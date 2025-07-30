defmodule Ayo.KnowledgeBase.Category.Changes.Amount do
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
    case Ash.Changeset.fetch_argument_or_attribute(changeset, opts[:attribute]) do
      {:ok, amount} when not is_nil(amount) ->
        money = Money.new(amount, :USD)

        Ash.Changeset.force_change_attribute(changeset, :monthly_budget, money)

      _ ->
        changeset
    end
  end
end