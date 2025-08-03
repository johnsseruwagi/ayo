defmodule AyoWeb.ExpenseLive.Show do
  use AyoWeb, :live_view


  @impl true
  def mount(params, _session, socket) do
    expense = Ayo.KnowledgeBase.Expense
      |> Ash.get!(params["id"], load: :category)

    category = Ayo.KnowledgeBase.Category
      |> Ash.get!(params["category_id"])

    socket =
      socket
      |> assign(page_title: "Show Expense")
      |> assign(expense: expense)
      |> assign(category: category)

    {:ok, socket}
  end


  # Helper functions
  defp format_money(%Money{} = money) do
    Money.to_string!(money)
  end
  defp format_money(_), do: "$0.00"


  @impl true
  def render(assigns) do
    ~H"""
      <Layouts.app flash={@flash} current_user={@current_user} >
        <.header>
          Expense Details
        <:subtitle>Expense in {@category.name}</:subtitle>
        <:actions>
          <.button_link
            variant="inverted_gradient"
            color="info"
            navigate={~p"/categories/#{@category}/expenses/#{@expense}/show/edit?return_to=show"}
          >
            Edit expense
          </.button_link>
        </:actions>
      </.header>

      <main>
        <.card
          variant="bordered"
          color="white"
          padding="medium"
          rounded="medium"
          space="large"

        >
          <.card_title
            position="center"
            class="border-b border-[#e4e4e7]"
            :if={@expense.description}
          >
            {@expense.description}
          </.card_title>

          <.card_content space="medium">
            <div>
              <label class="block text-sm font-medium text-gray-700">Amount</label>
              <p class="mt-1 text-3xl font-bold text-gray-900"> {format_money(@expense.amount)} </p>
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700">Date</label>
              <p class="mt-1 text-lg text-gray-900"> {Calendar.strftime(@expense.date, "%A, %B %d, %Y")} </p>
            </div>

            <div :if={@expense.notes}>
              <label class="block text-sm font-medium text-gray-700">Notes</label>
              <p class="mt-1 text-gray-900 whitespace-pre-wrap">{@expense.notes}</p>
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700">Category</label>
              <p class="mt-1 text-lg text-gray-900">{@expense.category.name}</p>
            </div>
          </.card_content>
          <.hr/>
          <.card_footer>
            <div class="text-sm text-gray-500 mb-1.5">
              <p>Created: {Calendar.strftime(@expense.inserted_at, "%B %d, %Y at %I:%M %p")}</p>
              <p :if={@expense.updated_at != @expense.inserted_at}>
                Last updated: {Calendar.strftime(@expense.updated_at, "%B %d, %Y at %I:%M %p")}
              </p>
            </div>
          </.card_footer>
        </.card>
        <.back navigate={~p"/categories/#{@category}/expenses"}>Back to expenses</.back>
      </main>
      </Layouts.app>
    """
  end

end