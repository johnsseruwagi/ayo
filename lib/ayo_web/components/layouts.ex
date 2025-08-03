defmodule AyoWeb.Layouts do
  @moduledoc """
  This module holds layouts and related functionality
  used by your application.
  """
  use AyoWeb, :html

  # Embed all files in layouts/* within this module.
  # The default root.html.heex file contains the HTML
  # skeleton of your application, namely HTML headers
  # and other static content.
  embed_templates "layouts/*"

  @doc """
  Renders your app layout.

  This function is typically invoked from every template,
  and it often contains your application menu, sidebar,
  or similar.

  ## Examples

      <Layouts.app flash={@flash}>
        <h1>Content</h1>
      </Layouts.app>

  """
  attr :flash, :map, required: true, doc: "the map of flash messages"

  attr :current_user, :map, default: nil, doc: "the current authenticated user"
  attr :current_uri, :string, default: "/", doc: "the current URI path"

  attr :current_scope, :map,
    default: nil,
    doc: "the current [scope](https://hexdocs.pm/phoenix/scopes.html)"

  slot :inner_block, required: true

  def app(assigns) do
    ~H"""
      <.navbar
        link="/"
        name="AYO"
        variant="bordered"
        color="white"
        id="main-navbar"
        padding="large"
      >
        <:list>
          <.nav_link navigate="/" current_uri={@current_uri}>
            Home
          </.nav_link>
        </:list>
        <:list>
          <.nav_link navigate={~p"/categories"} current_uri={@current_uri}>
            Category
          </.nav_link>
        </:list>
        <:list :if={@current_user}>
          <.nav_link navigate={~p"/"} current_uri={@current_uri}>
            Profile
          </.nav_link>
        </:list>
        <:list :if={@current_user}>
          <.link navigate={~p"/sign-out"} method="delete" class="text-gray-700 hover:text-red-600 transition-colors">
            Logout
          </.link>
        </:list>

        <:list :if={!@current_user}>
            <.nav_link navigate={~p"/register"} >
              Sign Up
            </.nav_link>
          </:list>
          <:list :if={!@current_user}>
            <.nav_link navigate={~p"/sign-in"} >
              Login
            </.nav_link>
          </:list>
        <:list>
          <.theme_toggle/>
        </:list>
      </.navbar>

      <main class="px-4 py-10 sm:px-6 lg:px-8">
        <div class="mx-auto max-w-4xl space-y-4">
          <.flash_group flash={@flash} />
          {render_slot(@inner_block)}
        </div>
      </main>
    """
  end

  @doc """
  Navigation link that highlights the active page
  """

  attr :navigate, :string, required: true
  attr :current_uri, :string, default: "/"
  attr :class, :string, default: ""
  slot :inner_block, required: true

  def nav_link(assigns) do
    # Normalize the navigate path
    navigate_path = case assigns.navigate do
      "/" -> "/"
      path -> path
    end

    # Normalize the current URI path
    current_path = case assigns.current_uri do
      nil -> "/"
      "/" -> "/"
      path -> path
    end

    # Check if current path matches the link path
    is_active = navigate_path == current_path || parse_nested_uri(navigate_path) == parse_nested_uri(current_path)


    assigns = assign(assigns, active: is_active)

    ~H"""
      <.link navigate={@navigate}
        class={[
        "transition-colors duration-200",
        if(@active, do: "text-cyan-600 font-semibold border-b-2 border-cyan-600", else: "text-gray-700 hover:text-blue-600"),
        @class
      ]}
      >
        {render_slot(@inner_block)}
      </.link>
    """
  end


  @doc """
  Shows the flash group with standard titles and content.

  ## Examples

      <.flash_group flash={@flash} />
  """
  attr :flash, :map, required: true, doc: "the map of flash messages"
  attr :id, :string, default: "flash-group", doc: "the optional id of flash container"

  def flash_group(assigns) do
    ~H"""
    <div id={@id} aria-live="polite" >
      <.flash
        kind={:info}
        class="fixed top-2 right-2 mr-2 w-80 sm:w-96 rounded-lg p-3 ring-1 bg-emerald-50 text-emerald-800 ring-emerald-500 fill-cyan-900"
        flash={@flash} />
      <.flash kind={:error} variant="default" class="fixed top-2 right-2 mr-2 w-80 sm:w-96 rounded-lg p-3 ring-1 bg-rose-50 text-rose-900 shadow-md ring-rose-500 fill-rose-900" flash={@flash} />

      <.flash
        id="client-error"
        kind={:error}
        class="fixed top-2 right-2 mr-2 w-80 sm:w-96 rounded-lg p-3 ring-1 bg-rose-50 text-rose-900 shadow-md ring-rose-500 fill-rose-900"
        title={gettext("We can't find the internet")}
        phx-disconnected={show(".phx-client-error #client-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#client-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>

      <.flash
        id="server-error"
        kind={:error}
        class="fixed top-2 right-2 mr-2 w-80 sm:w-96 rounded-lg p-3 ring-1 bg-rose-50 text-rose-900 shadow-md ring-rose-500 fill-rose-900"
        title={gettext("Something went wrong!")}
        phx-disconnected={show(".phx-server-error #server-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#server-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>
    </div>
    """
  end

  @doc """
  Provides dark vs light theme toggle based on themes defined in app.css.

  See <head> in root.html.heex which applies the theme before page load.
  """
  def theme_toggle(assigns) do
    ~H"""
    <div class="card relative flex flex-row items-center border-2 border-base-300 bg-base-300 rounded-full">
      <div class="absolute w-1/3 h-full rounded-full border-1 border-base-200 bg-base-100 brightness-200 left-0 [[data-theme=light]_&]:left-1/3 [[data-theme=dark]_&]:left-2/3 transition-[left]" />

      <button
        phx-click={JS.dispatch("phx:set-theme", detail: %{theme: "system"})}
        class="flex p-2 cursor-pointer w-1/3"
      >
        <.icon name="hero-computer-desktop-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>

      <button
        phx-click={JS.dispatch("phx:set-theme", detail: %{theme: "light"})}
        class="flex p-2 cursor-pointer w-1/3"
      >
        <.icon name="hero-sun-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>

      <button
        phx-click={JS.dispatch("phx:set-theme", detail: %{theme: "dark"})}
        class="flex p-2 cursor-pointer w-1/3"
      >
        <.icon name="hero-moon-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>
    </div>
    """
  end

  defp parse_nested_uri(uri) when is_binary(uri) do
    uri
    |> String.split("/")
    |> Enum.reject(& &1 == "")
    |> List.first()
  end
end
