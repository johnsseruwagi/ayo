defmodule Ayo.KnowledgeBase.Category.Validations.Amount do
  use Ash.Resource.Validation

  @impl true
  def init(opts) do
    if is_atom(opts[:attribute]) do
      {:ok, opts}
    else
      {:error, "attribute must be an atom!"}
    end
  end


  @impl true
  def supports(_opts), do: [Ash.Changeset]

  @impl true
  def validate(changeset, opts, _context) do
    case Ash.Changeset.get_attribute(changeset, opts[:attribute]) do
      %Money{amount: amount} when amount <= 0 ->
        {:error, field: opts[:attribute], message: "must be positive"}

      _ ->
        :ok
    end
  end
end