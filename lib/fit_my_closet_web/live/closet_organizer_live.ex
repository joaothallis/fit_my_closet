defmodule FitMyClosetWeb.ClosetOrganizerLive do
  use FitMyClosetWeb, :live_view

  alias FitMyCloset.Closets
  alias FitMyCloset.AI.Gemini

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:analyses, Closets.list_analyses())
     |> assign(:loading, false)
     |> assign(:form, to_form(Closets.change_analysis(%FitMyCloset.Closets.ClosetAnalysis{})))
     |> allow_upload(:image, accept: ~w(.jpg .jpeg .png), max_entries: 1)}
  end

  @impl true
  def handle_event("validate", %{"closet_analysis" => params}, socket) do
    form =
      %FitMyCloset.Closets.ClosetAnalysis{}
      |> Closets.change_analysis(params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, form: form)}
  end

  @impl true
  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :image, ref)}
  end

  @impl true
  def handle_event("save", %{"closet_analysis" => params}, socket) do
    image_paths =
      consume_uploaded_entries(socket, :image, fn %{path: path}, entry ->
        ext = Path.extname(entry.client_name)
        filename = "#{Path.basename(path)}#{ext}"
        dest = Path.join(["priv", "static", "uploads", filename])
        File.cp!(path, dest)
        {:ok, "/uploads/#{filename}"}
      end)

    case image_paths do
      [image_path] ->
        user_context = params["user_context"]
        case Closets.create_analysis(%{image_path: image_path, user_context: user_context}) do
          {:ok, analysis} ->
            # Trigger async analysis
            Task.async(fn ->
              # full path for file reading
              full_path = Path.join(["priv", "static", String.replace(image_path, "/uploads/", "uploads/")])
              result = Gemini.analyze_closet(full_path, user_context)
              {:analysis_complete, analysis.id, result}
            end)

            {:noreply,
             socket
             |> assign(:loading, true)
             |> put_flash(:info, "Image uploaded! Analyzing...")
             |> assign(:analyses, [analysis | socket.assigns.analyses])
             |> assign(:form, to_form(Closets.change_analysis(%FitMyCloset.Closets.ClosetAnalysis{})))}

          {:error, changeset} ->
            {:noreply, assign(socket, form: to_form(changeset))}
        end

      _ ->
        {:noreply, put_flash(socket, :error, "Please select an image.")}
    end
  end

  @impl true
  def handle_info({ref, {:analysis_complete, id, result}}, socket) do
    # Flush the :DOWN message
    Process.demonitor(ref, [:flush])
    
    require Logger
    Logger.info("Received analysis_complete for ID #{id}")
    
    analysis = Closets.get_analysis!(id)

    case result do
      {:ok, analysis_result} ->
        Logger.info("Analysis success for ID #{id}, updating DB...")
        {:ok, updated_analysis} = Closets.update_analysis(analysis, %{analysis_result: analysis_result})
        Logger.info("DB updated for ID #{id}")

        updated_analyses =
          Enum.map(socket.assigns.analyses, fn a ->
            if a.id == id, do: updated_analysis, else: a
          end)

        {:noreply,
         socket
         |> assign(:loading, false)
         |> assign(:analyses, updated_analyses)
         |> put_flash(:info, "Analysis complete!")}

      {:error, reason} ->
        {:noreply,
         socket
         |> assign(:loading, false)
         |> put_flash(:error, "Analysis failed: #{reason}")}
    end
  end

  # Handle Task cleanup
  @impl true
  def handle_info({:DOWN, _ref, :process, _pid, _reason}, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_info(msg, socket) do
    require Logger
    Logger.debug("Unhandled message in ClosetOrganizerLive: #{inspect(msg)}")
    {:noreply, socket}
  end
end
