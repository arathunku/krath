defmodule Krath.Schema.PolicySubjectRel do
  use Krath.Schema

  @primary_key false
  schema "krath_policy_subject_rel" do
    belongs_to(:policy, Krath.Schema.Policy, primary_key: true)
    belongs_to(:subject, Krath.Schema.Subject, primary_key: true)
  end
end
