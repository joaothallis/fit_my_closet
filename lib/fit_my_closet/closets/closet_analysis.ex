defmodule FitMyCloset.Closets.ClosetAnalysis do
  use Ecto.Schema
  import Ecto.Changeset

  schema "closet_analyses" do
    field :image_path, :string
    field :analysis_result, :map
    field :user_context, :string

    timestamps()
  end

  @doc false
  def changeset(closet_analysis, attrs) do
    closet_analysis
    |> cast(attrs, [:image_path, :analysis_result, :user_context])
    |> validate_required([:image_path])
  end
end
