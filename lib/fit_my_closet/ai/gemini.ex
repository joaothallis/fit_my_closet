defmodule FitMyCloset.AI.Gemini do
  @moduledoc """
  Client for the Google Gemini API.
  """

  @model "gemini-flash-latest"
  @base_url "https://generativelanguage.googleapis.com/v1beta/models"

  def analyze_closet(image_paths, user_context \\ nil) when is_list(image_paths) do
    api_key = Application.get_env(:fit_my_closet, :gemini_api_key)

    if is_nil(api_key) do
      {:error, "GEMINI_API_KEY is not configured"}
    else
      do_analyze(image_paths, user_context, api_key)
    end
  end

  defp do_analyze(image_paths, user_context, api_key) do
    image_parts =
      Enum.map(image_paths, fn path ->
        image_data = File.read!(path)
        mime_type = get_mime_type(path)

        %{
          "inline_data" => %{
            "mime_type" => mime_type,
            "data" => Base.encode64(image_data)
          }
        }
      end)

    context_prompt = if user_context && user_context != "", do: "\nAdditional context from the user: #{user_context}", else: ""

    body = %{
      "contents" => [
        %{
          "parts" => [
            %{
              "text" => """
              I am providing pictures of a closet. Please analyze them and identify different sections or areas of the closet.
              For each section, suggest the type of clothes that should be kept there (e.g., hanging space for dresses/coats, shelves for folded sweaters, drawers for underwear, top shelf for seasonal items).
              #{context_prompt}

              Return the result as a JSON object with a 'sections' key, which is a list of objects.
              Each object should have 'name', 'description', and 'recommended_clothes' (as a single string with items separated by commas).
              """
            }
            | image_parts
          ]
        }
      ],
      "generationConfig" => %{
        "responseMimeType" => "application/json"
      }
    }

    url = "#{@base_url}/#{@model}:generateContent?key=#{api_key}"

    require Logger
    Logger.info("Calling Gemini API for images: #{inspect(image_paths)}")

    case Req.post(url, json: body, receive_timeout: 60_000) do
      {:ok, %Req.Response{status: 200, body: body}} ->
        Logger.info("Gemini Request Success: 200")
        parse_response(body)

      {:ok, %Req.Response{status: status, body: body}} ->
        Logger.error("Gemini API error (Status #{status}): #{inspect(body)}")
        {:error, "Gemini API error (Status #{status})"}

      {:error, reason} ->
        Logger.error("Gemini API Request Failed: #{inspect(reason)}")
        {:error, reason}
    end
  end

  defp get_mime_type(path) do
    case Path.extname(path) |> String.downcase() do
      ".jpg" -> "image/jpeg"
      ".jpeg" -> "image/jpeg"
      ".png" -> "image/png"
      ".webp" -> "image/webp"
      _ -> "application/octet-stream"
    end
  end

  defp parse_response(body) do
    case get_in(body, ["candidates", Access.at(0), "content", "parts", Access.at(0), "text"]) do
      nil ->
        {:error, "Invalid response format from Gemini API"}

      text ->
        case Jason.decode(text) do
          {:ok, decoded} -> {:ok, decoded}
          {:error, _} -> {:error, "Failed to decode JSON from Gemini: #{text}"}
        end
    end
  end
end
