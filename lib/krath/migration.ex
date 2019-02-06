defmodule Krath.Migration do
  use Ecto.Migration

  def change do
    create table("krath_policies", primary_key: false) do
      add(:id, :bigserial, primary_key: true)
      add(:description, :text)
      add(:effect, :string, null: false, index: true)
      add(:conditions, :map, null: false, default: %{})

      timestamps()
    end

    create table("krath_subjects", primary_key: false) do
      add(:id, :bigserial, primary_key: true)
      add(:has_regex, :boolean, default: false, null: false)
      add(:template, :string, null: false, index: true)
      add(:compiled, :string, null: false, index: true)

      timestamps()
    end

    create table("krath_actions", primary_key: false) do
      add(:id, :bigserial, primary_key: true)
      add(:has_regex, :boolean, default: false, null: false)
      add(:template, :string, null: false, index: true)
      add(:compiled, :string, null: false, index: true)

      timestamps()
    end

    create table("krath_resources", primary_key: false) do
      add(:id, :bigserial, primary_key: true)
      add(:has_regex, :boolean, default: false, null: false)
      add(:template, :string, null: false, index: true)
      add(:compiled, :string, null: false, index: true)

      timestamps()
    end

    create table("krath_policy_subject_rel", primary_key: false) do
      add(:policy_id, references("krath_policies", on_delete: :delete_all, type: :bigserial), null: false, primary_key: true)
      add(:subject_id, references("krath_subjects", on_delete: :delete_all, type: :bigserial), null: false, primary_key: true)
    end

    create table("krath_policy_action_rel", primary_key: false) do
      add(:policy_id, references("krath_policies", on_delete: :delete_all, type: :bigserial), null: false, primary_key: true)
      add(:action_id, references("krath_actions", on_delete: :delete_all, type: :bigserial), null: false, primary_key: true)
    end

    create table("krath_policy_resource_rel", primary_key: false) do
      add(:policy_id, references("krath_policies", on_delete: :delete_all, type: :bigserial), null: false, primary_key: true)
      add(:resource_id, references("krath_resources", on_delete: :delete_all, type: :bigserial), null: false, primary_key: true)
    end
  end
end
