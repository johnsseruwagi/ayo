defmodule Ayo.KnowledgeBase.Category.Types.Category do
  use Ash.Type.Enum, values: [
    :food,
    :transportation,
    :entertainment,
    :utilities,
    :healthcare,
    :shopping,
    :other
  ]
end