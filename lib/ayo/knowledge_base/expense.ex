defmodule Ayo.KnowledgeBase.Expense do
  use Ash.Resource,
    otp_app: :ayo,
    domain: Ayo.KnowledgeBase,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "expenses"
    repo Ayo.Repo

    references do
      reference :category, on_delete: :delete, on_update: :update
    end
  end

  actions do
    defaults [:read, :destroy]

    create :create do
      primary? true
      accept [:description, :date, :notes, :category_id, :amount]

      argument :amount_value, :decimal do
        allow_nil? false
      end

      change {Ayo.KnowledgeBase.Category.Changes.Amount, [attribute1: :amount_value, attribute2: :amount]}
    end

    update :update do
      primary? true
      accept [:description, :date, :notes, :category_id, :amount]
      require_atomic? false
    end

    read :list do
      pagination offset?: true, countable: true, default_limit: 50
    end

    read :by_category do
      argument :category_id, :uuid, allow_nil?: false
      filter expr(category_id == ^arg(:category_id))
      pagination offset?: true, default_limit: 25
    end

    read :by_date_range do
      argument :start_date, :date, allow_nil?: false
      argument :end_date, :date, allow_nil?: false

      filter expr(date >= ^arg(:start_date) and date <= ^arg(:end_date))
    end

    read :recent do
      pagination offset?: true, default_limit: 10
      prepare build(sort: [date: :desc])
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :description, :string do
      allow_nil? false
      constraints [min_length: 1, max_length: 200]
    end

    attribute :amount, AshMoney.Types.Money do
      allow_nil? false
    end

    attribute :currency, :atom do
      default :USD
      allow_nil? false
      writable? false
    end

    attribute :date, :date do
      allow_nil? false
      default &Date.utc_today/0
    end

    attribute :notes, :string do
      constraints [max_length: 1000]
    end

    timestamps()
  end

  validations do
    validate present([:description, :amount, :category_id, :date])

    validate {Ayo.KnowledgeBase.Category.Validations.Amount, attribute: :amount}

    validate {Ayo.KnowledgeBase.Category.Validations.Date, attribute: :date}
  end

  relationships do
    belongs_to :category, Ayo.KnowledgeBase.Category do
      allow_nil? false
      attribute_writable? true
    end
  end
end