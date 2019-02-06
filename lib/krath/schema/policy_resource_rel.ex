defmodule Krath.Schema.PolicyResourceRel do
  use Krath.Schema

  @primary_key false
  # schema "krath_policy_resource_rel" do
  schema "krath_policy_resources_rel" do
    belongs_to(:policy, Krath.Schema.Policy, primary_key: true)
    belongs_to(:resource, Krath.Schema.Resource, primary_key: true)
  end
end
