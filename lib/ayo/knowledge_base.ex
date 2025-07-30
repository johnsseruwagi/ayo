defmodule Ayo.KnowledgeBase do
  use Ash.Domain,
    otp_app: :ayo

    resources do
      resource Ayo.KnowledgeBase.Category
      resource Ayo.KnowledgeBase.Expense
    end
end