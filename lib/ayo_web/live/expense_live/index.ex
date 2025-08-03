defmodule AyoWeb.ExpenseLive.Index do
  use AyoWeb, :live_view
  use Cinder.Table.UrlSync
  import Cinder.Table.Refresh

  require Ash.Query


  @impl true
  def mount(params, _sessions, socket) do
    category_id = params["category_id"]
    category = read_category(category_id)
    socket =
      socket
      |> assign(page_title: "Category Expenses")
      |> assign(category: category)

    {:ok, socket}
  end

  @impl true
  def handle_params(params, uri, socket) do
    socket = Cinder.Table.UrlSync.handle_params(params, uri, socket)
    uri = URI.parse(uri)
    current_uri = uri.path
    socket = assign(socket, current_uri: current_uri)

    {:noreply, socket}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    expense =
      Ayo.KnowledgeBase.Expense
      |> Ash.get!(id)

    Ash.destroy!(expense)
    socket = refresh_table(socket, "expenses-table")

    {:noreply, socket}
  end

  # Helper functions
  defp read_category(category_id) when is_binary(category_id) do
    Ayo.KnowledgeBase.Category
    |> Ash.get!(category_id)
  end

  defp format_money(%Money{} = money), do: Money.to_string!(money)
  defp format_money(_), do: "$0.00"

  @impl true
  def render(assigns) do
    ~H"""
      <Layouts.app flash={@flash} current_user={@current_user} current_uri={@current_uri}>
        <section class="h-screen">
          <.header>
            Expenses for {@category.name}
            <:subtitle>Track your spending in this category</:subtitle>
            <:actions>
              <.button_link variant="inverted_gradient" color="info" navigate={~p"/categories/#{@category}/expenses/new"}>
                New Expense
              </.button_link>
            </:actions>
          </.header>
          <main>
            <Cinder.Table.table
              query = {
                Ayo.KnowledgeBase.Expense
                |> Ash.Query.for_read(:list)
                |> Ash.Query.filter(category_id: @category.id)
              }
              id="expenses-table"
              theme="modern"
              url_state={@url_state}
              row_click={fn expense -> JS.navigate(~p"/categories/#{@category}/expenses/#{expense}") end}
            >
              <:col :let={expense} field="description" > {expense.description} </:col>
              <:col :let={expense} field="amount" sort filter > {format_money(expense.amount)} </:col>
              <:col :let={expense} field="date" sort filter > {Calendar.strftime(expense.date, "%B %d, %Y")} </:col>
              <:col :let={expense} field="notes" > {expense.notes} </:col>
              <:col :let={expense} field="actions" class="flex items-center" >
                <.button_link
                  variant="transparent"
                  color="primary"
                  size="small"
                  navigate={~p"/categories/#{@category}/expenses/#{expense}"}
                >
                  Show
                </.button_link>
                <.button_link
                  variant="transparent"
                  color="secondary"
                  size="small"
                  navigate={~p"/categories/#{@category}/expenses/#{expense}/edit"}
                >
                  Edit
                </.button_link>
                <.button
                  variant="transparent"
                  color="danger"
                  size="small"
                  phx-click={JS.push("delete", value: %{id: expense.id})}
                  data-confirm="Are you sure?"
                >
                  Delete
                </.button>
              </:col>
            </Cinder.Table.table>
            <.back navigate={~p"/categories/#{@category}"} >Back to category</.back>
          </main>
        </section>
      </Layouts.app>
    """
  end
end