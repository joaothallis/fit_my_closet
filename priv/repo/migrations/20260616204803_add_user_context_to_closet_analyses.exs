defmodule FitMyCloset.Repo.Migrations.AddUserContextToClosetAnalyses do
  use Ecto.Migration

  def change do
    alter table(:closet_analyses) do
      add :user_context, :text
    end
  end
end
