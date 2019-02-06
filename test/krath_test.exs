defmodule KrathTest do
  use Krath.DataCase, async: true

  @policies [
    %{
      subjects: ["max", "peter", "<zac|ken>"],
      resources: [
        "myrn:some.domain.com:resource:123",
        "myrn:some.domain.com:resource:345",
        "myrn:something:foo:.+"
      ],
      actions: ["<create|delete>", "get"],
      effect: "allow"
    },
    %{
      description: "This policy allows max to update any resource",
      subjects: ["max"],
      actions: ["update"],
      resources: ["<.*>"],
      effect: "allow"
    },
    %{
      description: "This policy denies max to broadcast any of the resources",
      subjects: ["max"],
      actions: ["broadcast"],
      resources: ["<.*>"],
      effect: "deny"
    }
  ]

  setup do
    @policies
    |> Enum.map(fn policy -> {:ok, _} = Krath.add_policy(policy) end)

    :ok
  end

  @requests [
    {
      "should pass because policy 1 is matching and has effect allow",
      ["peter", "myrn:some.domain.com:resource:123", "delete"],
      true
    },
    {
      "should pass because max is allowed to update all resources",
      ["max", "myrn:some.domain.com:resource:123", "update"],
      true
    },
    {
      "should pass because max is allowed to update all resource, even if none is given",
      ["max", "", "update"],
      true
    },
    {
      "should fail because max is not allowed to broadcast any resource",
      ["max", "myrn:some.domain.com:resource:123", "broadcast"],
      false
    },
    {
      "should fail because max is not allowed to broadcast any resource, even empty ones!",
      ["max", "", "broadcast"],
      false
    }
  ]
  describe "#access?" do
    test "Policies were added" do
      assert Krath.Repo.aggregate(Krath.Schema.Policy, :count, :id) == length(@policies)
      assert Krath.Repo.aggregate(Krath.Schema.Resource, :count, :id) == 4
      assert Krath.Repo.aggregate(Krath.Schema.Action, :count, :id) == 4
      assert Krath.Repo.aggregate(Krath.Schema.Subject, :count, :id) == 3
    end

    Enum.map(@requests, fn {description, input, output} ->
      @output output
      @input input
      test description do
        assert apply(Krath, :access?, @input) == @output
      end
    end)
  end
end
