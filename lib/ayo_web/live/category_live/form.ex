defmodule AyoWeb.CategoryLive.Form do
  use AyoWeb, :live_view


  @impl true
  def mount(params, _session, socket) do
    category =
      case params["id"] do
        nil -> nil
        id -> Ash.get!(Ayo.KnowledgeBase.Category, id)
      end

    action = if is_nil(category), do: "New", else: "Edit"
    page_title = action <> " " <> "Category"

    {:ok,
     socket
     |> assign(:return_to, return_to(params["return_to"]))
     |> assign(category: category)
     |> assign(:page_title, page_title)
     |> assign_form()}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  @impl true
  def handle_event("validate", %{"category" => category_params}, socket) do
    {:noreply,
     assign(socket, form: AshPhoenix.Form.validate(socket.assigns.form, category_params))}
  end

  def handle_event("save", %{"category" => category_params}, socket) do
    case AshPhoenix.Form.submit(socket.assigns.form, params: category_params) do
      {:ok, category} ->
        notify_parent({:saved, category})

        socket =
          socket
          |> put_flash(:info, "Category #{socket.assigns.form.source.type}d successfully")
          |> push_navigate(to: return_path(socket.assigns.return_to, category))

        {:noreply, socket}

      {:error, form} ->
        {:noreply, assign(socket, form: form)}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  defp assign_form(%{assigns: %{category: category}} = socket) do
    form =
      if category do
        budget_amount = Money.to_decimal(category.monthly_budget)
        AshPhoenix.Form.for_update(category, :update,
          as: "category",
          forms: [auto?: false],
          params: %{"monthly_budget_amount" => budget_amount}
        )
      else
        AshPhoenix.Form.for_create(Ayo.KnowledgeBase.Category, :create,
          as: "category",
          forms: [auto?: false]
        )
      end

    assign(socket, form: to_form(form))
  end

  defp return_path("index", _category), do: ~p"/categories"
  defp return_path("show", category), do: ~p"/categories/#{category.id}"

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage category records in your database.</:subtitle>
      </.header>

      <.form_wrapper space="medium" for={@form} id="category-form" phx-change="validate" phx-submit="save">
        <.text_field size="large" field={@form[:name]} label="Name" />
        <.textarea_field
          field={@form[:description]}
          label="Description"
          size="large"
        />
        <.number_field size="large" field={@form[:monthly_budget_amount]}  label="Monthly budget" />

        <.native_select
            field={@form[:category_type]}
            type="select"
            label="Category Type"
            size="large"
        >
          <:option :for={{name, value} <- [
              {"🍕 Food", :food},
              {"🚗 Transportation", :transportation},
              {"🎬 Entertainment", :entertainment},
              {"⚡ Utilities", :utilities},
              {"🏥 Healthcare", :healthcare},
              {"🛍️ Shopping", :shopping},
              {"📦 Other", :other}
            ]}
            value={value}
          >
            {name}
          </:option>
        </.native_select>

        <.button phx-disable-with="Saving..." variant="primary">Save Category</.button>
        <.button_link navigate={return_path(@return_to, @category)}>Cancel</.button_link>
      </.form_wrapper>
    </Layouts.app>
    """
  end
end
