defmodule Ayo.KnowledgeBase.Category do
  use Ash.Resource,
    otp_app: :ayo,
    domain: Ayo.KnowledgeBase,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "categories"
    repo Ayo.Repo
  end

  actions do
    defaults [:read, :update, :destroy]

    create :create do
      primary? true
      accept [:name, :description, :monthly_budget, :category_type]
      change {Ayo.KnowledgeBase.Category.Changes.Amount, attribute: :monthly_budget}
    end

    update :update_budget do
      accept [:monthly_budget]
      change {Ayo.KnowledgeBase.Category.Changes.MonthlyBudgetAmount, attribute: :monthly_budget}
    end

    read :list do
      primary? true
      pagination offset?: true, countable: true, default_limit: 25
    end

    read :by_type do
      argument :category_type, :atom, allow_nil?: false
      filter expr(category_type == ^arg(:category_type))
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :name, :string do
      allow_nil? false
      constraints [min_length: 1, max_length: 100]
    end

    attribute :description, :string do
      constraints [max_length: 500]
    end

    attribute :monthly_budget, AshMoney.Types.Money do
      allow_nil? false
    end

    attribute :currency, :atom do
      default :USD
      allow_nil? false
      writable? false
    end

    attribute :category_type, Ayo.KnowledgeBase.Category.Types.Category

    timestamps()
  end

  validations do
    validate present([:name, :monthly_budget])

    validate {Ayo.KnowledgeBase.Category.Validations.Amount, attribute: :monthly_budget}
  end

  relationships do
    has_many :expenses, Ayo.KnowledgeBase.Expense
  end

end