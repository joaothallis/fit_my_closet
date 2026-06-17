defmodule FitMyCloset.Repo.Migrations.DropImagePathFromClosetAnalyses do
  use Ecto.Migration

  def change do
    alter table(:closet_analyses) do
      remove :image_path, :string
    end
  end
end
