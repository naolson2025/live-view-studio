defmodule LiveViewStudioWeb.VolunteerFormComponent do
  use LiveViewStudioWeb, :live_component

  alias LiveViewStudio.Volunteers
  alias LiveViewStudio.Volunteers.Volunteer

  def mount(socket) do
    changeset = Volunteers.change_volunteer(%Volunteer{})

    {:ok, assign(socket, :form, to_form(changeset))}
  end

  # this is called automatically if not defined
  # and it will merge all assigns from the parent LiveView to the component
  # we can use it to update the state before rendering
  def update(assigns, socket) do
    socket =
      socket
      |> assign(assigns)
      |> assign(:count, assigns.count + 1)

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div>
      <div class="count">
        Go for it! You'll be number: <%= @count %>
      </div>
      <.form
        for={@form}
        phx-submit="save"
        phx-change="validate"
        phx-target={@myself}
      >
        <.input
          field={@form[:name]}
          placeholder="name"
          autocomplete="off"
          phx-debounce="2000"
        />
        <.input
          field={@form[:phone]}
          type="tel"
          placeholder="Phone"
          autocomplete="off"
          phx-debounce="blur"
        />
        <.button phx-disable-with="Saving...">Check In</.button>
      </.form>
    </div>
    """
  end

  def handle_event("validate", %{"volunteer" => volunteer_params}, socket) do
    changeset =
      %Volunteer{}
      |> Volunteers.change_volunteer(volunteer_params)
      # whenever action is not nil, the changeset errors will display
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, form: to_form(changeset))}
  end

  def handle_event("save", %{"volunteer" => volunteer_params}, socket) do
    # we added a publish message inside the Volunteers.create_volunteer function
    # that will broadcast the new volunteer to all subscribers
    # so all browsers will receive the new volunteer & update the list
    case Volunteers.create_volunteer(volunteer_params) do
      {:ok, _volunteer} ->
        # socket = update(socket, :volunteers, &[volunteer | &1])
        # insert volunteer at the top of the list (index 0)
        # socket = stream_insert(socket, :volunteers, volunteer, at: 0)
        # no longer need to send message to the parent component
        # bc we are broadcasting the message from the Volunteers.create_volunteer function
        # send(self(), {:volunteer_created, volunteer})
        changeset = Volunteers.change_volunteer(%Volunteer{})
        {:noreply, assign(socket, form: to_form(changeset))}

      {:error, changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end
end
