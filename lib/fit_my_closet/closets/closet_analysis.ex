defmodule FitMyCloset.Closets.ClosetAnalysis do
  use Ecto.Schema
  import Ecto.Changeset

  schema "closet_analyses" do
    field :analysis_result, :map
    field :user_context, :string
    has_many :images, FitMyCloset.Closets.ClosetImage

    timestamps()
  end

  @doc false
  def changeset(closet_analysis, attrs) do
    closet_analysis
    |> cast(attrs, [:analysis_result, :user_context])
    |> cast_assoc(:images)
  end
end
