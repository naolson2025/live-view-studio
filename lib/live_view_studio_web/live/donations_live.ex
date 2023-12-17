defmodule LiveViewStudioWeb.DonationsLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudio.Donations

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def sort_link(assigns) do
    ~H"""
    <.link patch={
      ~p"/donations?#{%{
        @options |
        sort_by: @sort_by,
        sort_order: next_sort_order(@options.sort_order)
      }}"
    }>
      <%= render_slot(@inner_block) %>
    </.link>
    """
  end

  # Automatically called after mount
  def handle_params(params, _uri, socket) do
    sort_by = (params["sort_by"] || "id") |> String.to_atom()
    sort_order = (params["sort_order"] || "asc") |> String.to_atom()

    page = (params["page"] || "1") |> String.to_integer()
    per_page = (params["per_page"] || "5") |> String.to_integer()

    options = %{
      sort_by: sort_by,
      sort_order: sort_order,
      page: page,
      per_page: per_page
    }

    donations = Donations.list_donations(options)
    {:noreply, assign(socket, donations: donations, options: options)}
  end

  def handle_event("select-per-page", %{"per-page" => per_page}, socket) do
    params = %{socket.assigns.options | per_page: per_page}

    # push patch will call handle_params
    socket = push_patch(socket, to: ~p"/donations?#{params}")

    {:noreply, socket}
  end

  defp next_sort_order(sort_order) do
    case sort_order do
      :asc -> :desc
      _ -> :asc
    end
  end
end
