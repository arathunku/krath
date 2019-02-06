defmodule Krath.PolicyQuery do
  import Ecto.Query
  alias Krath.Schema
  import Krath, only: [repo: 0]

  def matching_policies(subject, resource, action) do
    subject
    |> for_subject_query()
    |> join(:inner, [p], a in assoc(p, :actions))
    |> join(:inner, [p], r in assoc(p, :resources))
    |> where([p, s, a, r], fragment("
      ? IS FALSE AND ? = ? OR ? IS TRUE AND ? ~ ?
    ", r.has_regex, r.template, ^resource, r.has_regex, ^resource, r.compiled))
    |> where([p, s, a, r], fragment("
      ? IS FALSE AND ? = ? OR ? IS TRUE AND ? ~ ?
    ", a.has_regex, a.template, ^action, a.has_regex, ^action, a.compiled))
    |> repo().all()
  end

  def for_subject(subject) do
    for_subject_query(subject)
    |> preload([:actions, :resources])
    |> repo().all()
  end

  defp for_subject_query(subject) do
    from(p in Schema.Policy,
      select: [:id, :effect],
      join: s in assoc(p, :subjects),
      where: fragment("
      ? IS FALSE AND ? = ? OR ? IS TRUE AND ? ~ ?
    ", s.has_regex, s.template, ^subject, s.has_regex, ^subject, s.compiled)
    )
  end
end
