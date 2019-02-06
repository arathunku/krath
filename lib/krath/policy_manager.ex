defmodule Krath.PolicyManager do
  alias Krath.Schema
  alias Ecto.Multi
  import Ecto.Query

  def add(%{subjects: subjects, actions: actions, resources: resources} = policy) do
    if Map.has_key?(policy, :conditions) do
      raise ArgumentError, "Conditoins are currently not supported"
    end

    Multi.new()
    |> Multi.insert(:policy, Schema.Policy.create(policy))
    |> append_subjects(subjects)
    |> append_actions(actions)
    |> append_resources(resources)
    |> append_subject_relations(subjects)
    |> append_action_relations(actions)
    |> append_resource_relations(resources)
    |> Krath.repo().transaction()
    |> case do
      {:ok, %{policy: policy}} -> {:ok, policy}
      error -> error
    end
  end

  def delete(%Schema.Policy{} = policy) do
    result =
      Multi.new()
      |> Multi.delete(:policy, policy)
      |> Multi.run(:clean_orphaned_resources, fn repo, _ ->
        clean_orphaned(repo, Schema.Resource)
      end)
      |> Multi.run(:clean_orphaned_actions, fn repo, _ ->
        clean_orphaned(repo, Schema.Action)
      end)
      |> Multi.run(:clean_orphaned_subjects, fn repo, _ ->
        clean_orphaned(repo, Schema.Subject)
      end)
      |> Krath.repo().transaction()

    with {:ok, _} <- result do
      :ok
    end
  end

  defp append_subjects(multi, subjects),
    do: append_list(multi, subjects, Schema.Subject, "subject")

  defp append_resources(multi, subjects),
    do: append_list(multi, subjects, Schema.Resource, "resource")

  defp append_actions(multi, subjects), do: append_list(multi, subjects, Schema.Action, "action")

  defp append_subject_relations(multi, subjects),
    do: append_relations(multi, subjects, Schema.PolicySubjectRel, :subject_id, "subject")

  defp append_action_relations(multi, actions),
    do: append_relations(multi, actions, Schema.PolicyActionRel, :action_id, "action")

  defp append_resource_relations(multi, resources),
    do: append_relations(multi, resources, Schema.PolicyResourceRel, :resource_id, "resource")

  defp append_relations(multi, elements, schema, attribute, prefix) do
    Multi.run(multi, String.to_atom("#{prefix}_relations"), fn repo, data ->
      relations =
        elements
        |> Enum.with_index()
        |> Enum.map(fn {_, i} ->
          key = String.to_atom("#{prefix}_#{i}")
          policy_id = data |> Map.get(:policy) |> Map.get(:id)
          id = data |> Map.fetch!(key) |> Map.get(:id)

          %{policy_id: policy_id}
          |> Map.put(attribute, id)
        end)

      repo.insert_all(schema, relations, on_conflict: :nothing)
      |> case do
        {_, _} -> {:ok, nil}
      end
    end)
  end

  # TODO: FIX AUTO GENERATED ATOMS. Pregenerate 100 atoms and then use existing
  defp append_list(multi, [], _schema, _key), do: multi

  defp append_list(multi, [template | elements], schema, prefix) do
    key = String.to_atom("#{prefix}_#{length(elements)}")
    set_key = String.to_atom("set_#{key}")

    multi
    |> Multi.run(set_key, fn repo, _ ->
      case repo.get_by(schema, template: template) do
        nil -> {:ok, struct(schema)}
        v -> {:ok, v}
      end
    end)
    |> Multi.insert_or_update(key, fn data ->
      subject = Map.get(data, set_key)
      {:ok, compiled} = Krath.RegexCompiler.compile(template)

      schema.changeset(subject, %{
        template: template,
        compiled: compiled,
        has_regex: compiled != template
      })
    end)
    |> append_list(elements, schema, prefix)
  end

  def clean_orphaned(repo, schema) do
    orphans = from(r in schema,
      left_join: p in assoc(r, :policies),
      group_by: r.id ,
      having: count(p.id) == 0,
      select: [:id, :template]
    )

    from(p in schema, join: s in subquery(orphans), on: p.id == s.id)
    |> repo.delete_all()
    |> case do
      {_, _} -> {:ok, nil}
    end
  end
end
