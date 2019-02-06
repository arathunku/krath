defmodule Krath do
  alias Krath.{PolicyManager, PolicyQuery}

  defdelegate add_policy(policy), to: PolicyManager, as: :add

  @doc """
  Check if given action on resource is available to subject.

  If there's any matching policy that's on `deny`, it will be false.
  """
  def access?(subject, resource, action) do
    PolicyQuery.matching_policies(subject, resource, action)
    |> Enum.sort_by(fn %{effect: effect} ->
      case effect do
        "deny" -> 0
        "allow" -> 1
      end
    end)
    |> check_permission()
  end

  def repo() do
    Application.fetch_env!(:krath, :repo)
  end

  # TODO: later on check by conditions, if they match
  defp check_permission([]), do: false
  defp check_permission([candidate | _]) do
    if Map.get(candidate, :effect) == "deny" do
      false
    else
      true
    end
  end
end
