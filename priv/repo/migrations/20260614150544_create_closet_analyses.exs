defmodule FitMyCloset.Repo.Migrations.CreateClosetAnalyses do
  use Ecto.Migration

  def change do
    create table(:closet_analyses) do
      add :image_path, :string, null: false
      add :analysis_result, :map

      timestamps()
    end
  end
end
