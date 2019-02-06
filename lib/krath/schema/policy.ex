defmodule Krath.Schema.Policy do
  use Krath.Schema

  schema "krath_policies" do
    field(:description)
    field(:effect)
    field(:conditions, :map, default: %{})

    has_many(:policy_subjects, Schema.PolicySubjectRel)
    has_many(:subjects, through: [:policy_subjects, :subject])

    has_many(:policy_actions, Schema.PolicyActionRel)
    has_many(:actions, through: [:policy_actions, :action])

    has_many(:policy_resources, Schema.PolicyResourceRel)
    has_many(:resources, through: [:policy_resources, :resource])

    timestamps()
  end

  def create(params) do
    changeset(%__MODULE__{}, params)
  end

  defp changeset(struct, params) do
    struct
    |> cast(params, ~w(effect description)a)
    |> validate_inclusion(:effect, ~w(deny allow))
    |> validate_required(~w(effect)a)
  end
end
