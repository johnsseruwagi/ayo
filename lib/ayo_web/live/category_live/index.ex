defmodule AyoWeb.CategoryLive.Index do
  use AyoWeb, :live_view

  alias Ayo.KnowledgeBase.Category

  @impl true
  def mount(_params, _session, socket) do

    {:ok,
     socket
     |> assign(:page_title, "Listing Categories")
     |> stream(
       :categories,
       list_categories()
     )}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    category = Ash.get!(Ayo.KnowledgeBase.Category, id)
    Ash.destroy!(category)

    {:noreply, stream_delete(socket, :categories, category)}
  end

  # Helper functions
  defp list_categories do
    Category
    |> Ash.read!()
  end

  defp category_type_badge(type) do
    case type do
      :food -> "🍕 Food"
      :transportation -> "🚗 Transportation"
      :entertainment -> "🎬 Entertainment"
      :utilities -> "⚡ Utilities"
      :healthcare -> "🏥 Healthcare"
      :shopping -> "🛍️ Shopping"
      :other -> "📦 Other"
    end
  end

  defp format_money(%Money{} = money) do
    Money.to_string(money)
  end

  defp format_money(_), do: "$0.00"

  defp progress_bar_color(percentage) when percentage >= 90, do: "bg-red-500"
  defp progress_bar_color(percentage) when percentage >= 75, do: "bg-yellow-500"
  defp progress_bar_color(_), do: "bg-green-500"

  # Render categories
  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Expense Categories
        <:subtitle>Manage your expense categories and budgets</:subtitle>
        <:actions>
          <.button_link variant="primary" icon="hero-plus" navigate={~p"/categories/new"}>
            New Category
          </.button_link>
        </:actions>
      </.header>

      <main>
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6 mt-8">
        <div
        :for={{id, category} <- @streams.categories}
        id={id}
        class="bg-white rounded-lg shadow-md p-6 hover:shadow-lg transition-shadow"
        >
        <div class="flex justify-between items-start mb-4">
          <div>
            <h3 class="text-lg font-semibold text-gray-900">{category.name}</h3>
            <p class="text-sm text-gray-600"><%= category_type_badge(category.category_type) %></p>
          </div>
          <div class="flex space-x-2">
            <.link navigate={~p"/categories/#{category}/edit"} class="text-blue-600 hover:text-blue-800">
              <.icon name="hero-pencil-solid" class="h-4 w-4" />
            </.link>
            <.link
              phx-click={JS.push("delete", value: %{id: category.id}) |> hide("##{id}")}
              data-confirm="Are you sure?"
              class="text-red-600 hover:text-red-800"
            >
              <.icon name="hero-trash-solid" class="h-4 w-4" />
            </.link>
          </div>
        </div>

        <p :if={category.description} class="text-sm text-gray-600 mb-4"><%= category.description %></p>

        <div class="space-y-3">
          <div class="flex justify-between items-center">
            <span class="text-sm font-medium text-gray-700">Budget</span>
            <span class="text-sm font-semibold"><%= format_money(category.monthly_budget) %></span>
          </div>

          <div class="flex justify-between items-center">
            <span class="text-sm font-medium text-gray-700">Spent</span>
            <span class="text-sm font-semibold"><%= format_money(category.total_spent) %></span>
          </div>

          <!-- Progress Bar -->
          <div class="w-full bg-gray-200 rounded-full h-2">
            <div
              class={"h-2 rounded-full transition-all duration-300 #{progress_bar_color(category.budget_percentage)}"}
              style={"width: #{min(category.budget_percentage, 100)}%"}
            >
            </div>
          </div>

          <div class="flex justify-between items-center">
            <span class="text-xs text-gray-500">
              <%= Float.round(category.budget_percentage, 1) %>% of budget used
            </span>
            <span :if={category.budget_percentage > 100} class="text-xs text-red-600 font-medium">
              Over budget!
            </span>
          </div>
        </div>

        <div class="mt-6 pt-4 border-t border-gray-200">
          <.link
            navigate={~p"/categories/#{category}"}
            class="text-blue-600 hover:text-blue-800 font-medium text-sm"
          >
            View Details →
          </.link>
        </div>
        </div>
        </div>
      </main>

    </Layouts.app>
    """
  end
end
