defmodule Krath.Schema.Resource do
  use Krath.Schema

  schema "krath_resources" do
    field(:has_regex, :boolean, default: false)
    field(:template)
    field(:compiled)

    many_to_many(:policies, Schema.Policy, join_through: "krath_policy_resources_rel")

    timestamps()
  end

  def changeset(struct, params) do
    struct
    |> cast(params, ~w(template compiled has_regex)a)
    |> validate_inclusion(:has_regex, [true, false])
    |> validate_required(~w(template compiled)a)
  end
end
