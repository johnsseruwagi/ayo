defmodule AyoWeb.CategoryLive.Show do
  use AyoWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Category {@category.id}
        <:subtitle>This is a category record from your database.</:subtitle>

        <:actions>
          <.button navigate={~p"/categories"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/categories/#{@category}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit Category
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Id">{@category.id}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Show Category")
     |> assign(
       :category,
       Ash.get!(Ayo.KnowledgeBase.Category, id, actor: socket.assigns.current_user)
     )}
  end
end
