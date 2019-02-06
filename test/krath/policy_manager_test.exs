defmodule Krath.PolicyManagerTest do
  use Krath.DataCase, async: true
  alias Krath.{PolicyManager, Schema, Repo}

  describe "#add" do
    test "returns policy with id" do
      policy = %{subjects: ["foobar"], resources: [], actions: [], effect: "allow"}
      {:ok, result} = PolicyManager.add(policy)

      assert !!result.id
    end

    test "doesnt add duplicated actions, subjects" do
      policy = %{subjects: ["foobar"], resources: ["fooresource"], actions: ["fooaction"], effect: "allow"}
      {:ok, _} = PolicyManager.add(policy)
      policy = %{subjects: ["foobar"], resources: ["fooresource"], actions: ["fooaction"], effect: "allow"}
      {:ok, _} = PolicyManager.add(policy)

      assert templates(Repo.all(Schema.Action)) == ["fooaction"]
      assert templates(Repo.all(Schema.Subject)) == ["foobar"]
      assert templates(Repo.all(Schema.Resource)) == ["fooresource"]
    end
  end

  describe "#delete" do
    test "removes policy and all its references subjects, actions, resources" do
      policy = %{subjects: ["foobar"], resources: ["fooresource"], actions: ["fooaction"], effect: "allow"}
      {:ok, policy} = PolicyManager.add(policy)

      :ok = PolicyManager.delete(policy)

      assert Repo.all(Schema.Policy) == []
      assert Repo.all(Schema.Resource) == []
      assert Repo.all(Schema.Action) == []
      assert Repo.all(Schema.Subject) == []
    end

    test "cleans up resources/actions/subject only if nothing else references them" do

      policy = %{subjects: ["foobar"], resources: ["fooresource"], actions: ["fooaction"], effect: "allow"}
      {:ok, policy} = PolicyManager.add(policy)
      policy2 = %{subjects: ["foobar2"], resources: ["fooresource1"], actions: ["fooaction"], effect: "allow"}
      {:ok, _} = PolicyManager.add(policy2)

      :ok = PolicyManager.delete(policy)

      assert templates(Repo.all(Schema.Action)) == ["fooaction"]
      assert templates(Repo.all(Schema.Subject)) == ["foobar2"]
      assert templates(Repo.all(Schema.Resource)) == ["fooresource1"]
    end
  end

  def templates(list) do
    Enum.map(list, & Map.get(&1, :template))
  end
end
