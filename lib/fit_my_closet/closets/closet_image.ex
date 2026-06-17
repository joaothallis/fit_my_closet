defmodule FitMyCloset.Closets.ClosetImage do
  use Ecto.Schema
  import Ecto.Changeset

  schema "closet_images" do
    field :image_path, :string
    belongs_to :closet_analysis, FitMyCloset.Closets.ClosetAnalysis

    timestamps()
  end

  @doc false
  def changeset(closet_image, attrs) do
    closet_image
    |> cast(attrs, [:image_path, :closet_analysis_id])
    |> validate_required([:image_path])
  end
end
