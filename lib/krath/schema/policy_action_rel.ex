defmodule Krath.Schema.PolicyActionRel do
  use Krath.Schema

  @primary_key false
  schema "krath_policy_action_rel" do
    belongs_to(:policy, Krath.Schema.Policy, primary_key: true)
    belongs_to(:action, Krath.Schema.Action, primary_key: true)
  end
end
