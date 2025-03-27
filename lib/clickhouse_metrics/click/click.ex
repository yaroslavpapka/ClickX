defmodule ClickhouseMetrics.Click do
  use Ecto.Schema
  import Ecto.Changeset

  schema "clicks" do
    field :ip, :string
    field :user_agent, :string
    field :browser, :string
    field :device, :string

    timestamps()
  end

  def changeset(click, attrs) do
    click
    |> cast(attrs, [:ip, :user_agent, :browser, :device])
    |> validate_required([:ip, :user_agent, :browser, :device])
  end
end
