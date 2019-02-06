defmodule Krath.PolicyQueryTest do
  use Krath.DataCase, async: true
  alias Krath.{PolicyManager, PolicyQuery}

  @policies [
    %{
      subjects: ["max", "peter"],
      resources: [
        "myrn:something:foo:.+"
      ],
      actions: ["get"],
      effect: "allow"
    }
  ]

  setup do
    @policies
    |> Enum.map(fn policy -> {:ok, _} = PolicyManager.add(policy) end)

    :ok
  end

  describe "#for_subject" do
    test "returns 1 element for peter (first policy via string match)" do
      result = PolicyQuery.for_subject("peter")
      actions = Enum.map(Map.get(hd(result), :actions), & Map.get(&1, :template))
      assert length(result) == 1
      assert actions == ~w(get)
    end
  end
end
