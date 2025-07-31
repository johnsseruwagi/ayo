defmodule AyoWeb.ExpenseLive.Form do
  use AyoWeb, :live_view
  
  @impl true
  def mount(params, _session, socket) do

    expense =
      case params["id"] do
        nil -> nil
        expense_id ->
          Ash.get!(Ayo.KnowledgeBase.Expense, expense_id)
      end

    action = if is_nil(expense), do: "New", else: "Edit"
    page_title = action <> " " <> "Expense"

    socket =
      socket
      |> assign(return_to: return_to(params["return_to"]))
      |> assign(category: Ash.get!(Ayo.KnowledgeBase.Category, params["category_id"]))
      |> assign(expense: expense)
      |> assign(page_title: page_title)
      |> assign_form()

    {:ok, socket}
  end

  @impl true
  def handle_event("validate", %{"expense" => expense_params}, socket) do
    socket = assign(socket, form: AshPhoenix.Form.validate(socket.assigns.form, expense_params))
    {:noreply, socket}
  end

  def handle_event("save", %{"expense" => expense_params}, socket) do
    IO.inspect(socket.assigns.form, label: "Form before submit")
    case AshPhoenix.Form.submit(socket.assigns.form, params: expense_params) do
      {:ok, expense} ->
        notify_parent({:saved, expense})

        socket =
          socket
          |> put_flash(:info, "Expense #{socket.assigns.form.source.type}d successfully")
          |> push_navigate(to: return_path(socket.assigns.return_to, {socket.assigns.category, expense}))

        {:noreply, socket}

      {:error, form} ->
        {:noreply, assign(socket, form: form)}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  # Helper functions
  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  defp return_path("index", {category, _expense}), do: ~p"/categories/#{category}/expenses"
  defp return_path("show", {category, expense}), do: ~p"/categories/#{category}/expenses/#{expense.id}"
  
  defp assign_form(%{assigns: %{expense: expense, category: category}} = socket) do
    form = 
      if expense do
        amount_value = Money.to_decimal(expense.amount)
        AshPhoenix.Form.for_update(expense, :update,
            as: "expense",
            forms: [auto?: false],
            params: %{"amount_value" => amount_value}
        )

      else
        Ayo.KnowledgeBase.Expense
        |> AshPhoenix.Form.for_create(:create,
          as: "expense",
          forms: [auto?: false],
          params: %{"category_id" => category.id}
        )
      end

    assign(socket, form: to_form(form))
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        {@page_title}
        <:subtitle>Add or edit expenses for {@category.name}</:subtitle>
      </.header>

      <.form_wrapper space="medium" for={@form} id="expense-form" phx-change="validate" phx-submit="save">
        <.textarea_field
          field={@form[:description]}
          label="Description"
          size="large"
        />
        <.number_field size="large" field={@form[:amount_value]}  label="Amount" />
        <.date_time_field size="large" field={@form[:date]} type="date" label="Date" />
        <.textarea_field
          field={@form[:notes]}
          label="Notes (optional)"
          size="large"
        />

        <.input field={@form[:category_id]} type="hidden" value={@category.id}/>

        <.button phx-disable-with="Saving..." variant="primary">Save Category</.button>
        <.button_link navigate={return_path(@return_to, {@category, @expense})}>
          Cancel
        </.button_link>
      </.form_wrapper>
    </Layouts.app>
    """
  end
end