defmodule Ayo.KnowledgeBase.Category.Changes.Amount do
  use Ash.Resource.Change

  @impl true
  def init(opts) do
    if is_atom(opts[:attribute1]) and is_atom(opts[:attribute2]) do
      {:ok, opts}
    else
      {:error, "attribute must be an atom!"}
    end
  end

  @impl true
  def change(changeset, opts, _context) do
    case Ash.Changeset.fetch_argument_or_attribute(changeset, opts[:attribute1]) do
      {:ok, amount} when not is_nil(amount) ->
        money = Money.new(amount, :USD)

        Ash.Changeset.force_change_attribute(changeset, opts[:attribute2], money)

      _ ->
        changeset
    end
  end
end