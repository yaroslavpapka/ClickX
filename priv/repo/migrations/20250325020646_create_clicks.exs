defmodule ClickhouseMetrics.Repo.Migrations.CreateClicks do
  use Ecto.Migration

  def change do
    create table(:clicks) do
      add :ip, :string
      add :user_agent, :string
      add :browser, :string
      add :device, :string
      timestamps()
    end
  end
end
