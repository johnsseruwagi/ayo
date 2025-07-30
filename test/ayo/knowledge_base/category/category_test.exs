defmodule Ayo.KnowledgeBase.CategoryTest do
  use Ayo.DataCase

  alias Ayo.KnowledgeBase.Category
  require Ash.Query

  describe "category creations" do
    test "success: allows valid attributes" do
      attrs = %{
        name: "Chips",
        category_type: "food",
        monthly_budget_amount: 40000,
        monthly_budget: Money.new(0, :USD),
        description: "this is for eating fries"
      }

      assert {:ok, category} = Category
        |> Ash.Changeset.for_create(:create, attrs)
        |> Ash.create()

      IO.inspect category
    end
  end
end