defmodule Ayo.KnowledgeBase.Category.Validations.Date do
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
      %Date{} = date ->
        if Date.compare(date, Date.utc_today()) == :gt do
          {:error, field: opts[:attribute], message: "cannot be in the future"}
        else
          :ok
        end

      _ ->
        :ok
    end
  end
end