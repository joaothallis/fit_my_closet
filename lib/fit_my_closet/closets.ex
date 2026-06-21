defmodule FitMyCloset.Closets do
  @moduledoc """
  The Closets context.
  """

  import Ecto.Query, warn: false
  alias FitMyCloset.Closets.ClosetAnalysis
  alias FitMyCloset.Repo

  @doc """
  Returns the list of closet_analyses.
  """
  def list_analyses do
    Repo.all(from c in ClosetAnalysis, order_by: [desc: c.inserted_at], preload: [:images])
  end

  @doc """
  Gets a single closet_analysis.
  """
  def get_analysis!(id), do: Repo.get!(ClosetAnalysis, id) |> Repo.preload(:images)

  @doc """
  Creates a closet_analysis.
  """
  def create_analysis(attrs \\ %{}) do
    %ClosetAnalysis{}
    |> ClosetAnalysis.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a closet_analysis.
  """
  def update_analysis(%ClosetAnalysis{} = closet_analysis, attrs) do
    closet_analysis
    |> ClosetAnalysis.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a closet_analysis.
  """
  def delete_analysis(%ClosetAnalysis{} = closet_analysis) do
    Repo.delete(closet_analysis)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking closet_analysis changes.
  """
  def change_analysis(%ClosetAnalysis{} = closet_analysis, attrs \\ %{}) do
    ClosetAnalysis.changeset(closet_analysis, attrs)
  end
end
