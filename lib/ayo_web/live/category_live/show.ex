defmodule AyoWeb.CategoryLive.Show do
  use AyoWeb, :live_view


  @impl true
  def mount(%{"id" => id}, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Show Category")
     |> assign(
       :category,
       Ash.get!(Ayo.KnowledgeBase.Category, id, load: [:total_spent, :budget_percentage, :recent_expenses])
     )}
  end

  @impl true
  def handle_params(_params, url, socket) do
    uri = URI.parse(url)
    current_uri = uri.path || "/"
    socket = assign(socket, current_uri: current_uri)

    {:noreply, socket}
  end


  # Helper functions
  defp format_money(%Money{} = money), do: Money.to_string!(money)
  defp format_money(_), do: "$0.00"

  defp progress_bar_color(percentage) when percentage >= 90, do: "bg-red-500"
  defp progress_bar_color(percentage) when percentage >= 75, do: "bg-yellow-500"
  defp progress_bar_color(_), do: "bg-green-500"

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

  attr :category, Ayo.KnowledgeBase.Category, required: true
  def category_section(assigns) do
    ~H"""
      <div class="grid grid-cols-1 lg:grid-cols-3 gap-8 mt-8">
        <!-- Category Info -->
        <div class="lg:col-span-1">
          <div class="bg-white rounded-lg shadow p-6">
            <h3 class="text-lg font-semibold mb-4">Category Details</h3>

            <div class="space-y-4">
              <div>
                <label class="block text-sm font-medium text-gray-700">Description</label>
                <p class="mt-1 text-sm text-gray-900"><%= @category.description || "No description" %></p>
              </div>

              <div>
                <label class="block text-sm font-medium text-gray-700">Monthly Budget</label>
                <p class="mt-1 text-2xl font-bold text-gray-900"><%= format_money(@category.monthly_budget) %></p>
              </div>

              <div>
                <label class="block text-sm font-medium text-gray-700">Total Spent</label>
                <p class="mt-1 text-2xl font-bold text-gray-900"><%= format_money(@category.total_spent) %></p>
              </div>

              <!-- Progress Bar -->
              <div>
                <div class="flex justify-between items-center mb-2">
                  <label class="block text-sm font-medium text-gray-700">Budget Usage</label>
                  <span class="text-sm text-gray-600"><%= Float.round(@category.budget_percentage, 1) %>%</span>
                </div>
                <div class="w-full bg-gray-200 rounded-full h-3">
                  <div
                    class={"h-3 rounded-full transition-all duration-300 #{progress_bar_color(@category.budget_percentage)}"}
                    style={"width: #{min(@category.budget_percentage, 100)}%"}
                  >
                  </div>
                </div>
                <p :if={@category.budget_percentage > 100} class="mt-1 text-sm text-red-600 font-medium">
                  Over budget by <%= format_money(Money.sub!(@category.total_spent, @category.monthly_budget)) %>
                </p>
              </div>
            </div>
          </div>
        </div>
      </div>

    """
  end

  attr :category, Ayo.KnowledgeBase.Category, required: true
  def recent_expenses_section(assigns) do
    ~H"""
      <div class="lg:col-span-2 my-20">
        <div class="bg-white rounded-lg shadow p-6">
          <div class="flex justify-between items-center mb-4">
            <h3 class="text-lg font-semibold">Recent Expenses</h3>
            <.button_link
              variant="outline"
              color="secondary"
              size="small"
              navigate={~p"/categories/#{@category}/expenses/new"}
            >
              Add Expense
            </.button_link>
          </div>

          <div :if={Enum.empty?(@category.recent_expenses)} class="text-center py-8">
            <.icon name="hero-currency-dollar" class="mx-auto h-12 w-12 text-gray-400" />
            <h3 class="mt-2 text-sm font-medium text-gray-900">No expenses yet</h3>
            <p class="mt-1 text-sm text-gray-500">Get started by adding your first expense.</p>
            <div class="mt-6">
              <.button_link
                variant="outline"
                color="secondary"
                size="small"
                navigate={~p"/categories/#{@category}/expenses/new"}
              >
                Add Expense
              </.button_link>
            </div>
          </div>

          <div :if={not Enum.empty?(@category.recent_expenses)} class="space-y-3">
            <div
              :for={expense <- @category.recent_expenses}
              class="flex justify-between items-center p-3 bg-gray-50 rounded-lg"
            >
              <div class="flex-1">
                <p class="font-medium text-gray-900"><%= expense.description %></p>
                <p class="text-sm text-gray-600"><%= Calendar.strftime(expense.date, "%B %d, %Y") %></p>
                <p :if={expense.notes} class="text-xs text-gray-500 mt-1"><%= expense.notes %></p>
              </div>
              <div class="text-right">
                <p class="font-semibold text-gray-900"><%= format_money(expense.amount) %></p>
              </div>
            </div>

            <div class="pt-4 border-t">
              <.link
                navigate={~p"/categories/#{@category}/expenses"}
                class="text-blue-600 hover:text-blue-800 font-medium text-sm"
              >
                View all expenses →
              </.link>
            </div>
          </div>
        </div>
      </div>
    """
  end

  @impl true
  def render(assigns) do
    ~H"""
      <Layouts.app flash={@flash} current_user={@current_user} current_uri={@current_uri}>
        <.header>
          {@category.name}
          <:subtitle><%= category_type_badge(@category.category_type) %></:subtitle>
          <:actions>
            <.button_link
              variant="bordered"
              color="info"
              navigate={~p"/categories/#{@category}/show/edit?return_to=show"}
            >
              Edit category
            </.button_link>
            <.button_link
              navigate={~p"/categories/#{@category}/expenses"}
              variant="default_gradient"
              color="info"
            >
              Manage Expenses
            </.button_link>
          </:actions>
        </.header>

        <main>
          <.category_section category={@category}/>
          <.recent_expenses_section category={@category} />
          <.back navigate={~p"/categories"}>Back to categories</.back>
        </main>
    </Layouts.app>
    """
  end
end
