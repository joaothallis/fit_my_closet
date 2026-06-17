defmodule FitMyCloset.Repo.Migrations.CreateClosetImages do
  use Ecto.Migration

  def change do
    create table(:closet_images) do
      add :image_path, :string, null: false
      add :closet_analysis_id, references(:closet_analyses, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:closet_images, [:closet_analysis_id])
  end
end
