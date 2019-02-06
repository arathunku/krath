defmodule Krath.Schema do
  defmacro __using__([]) do
    quote do
      use Ecto.Schema
      @primary_key {:id, :integer, read_after_writes: true}
      @foreign_key_type :integer
      @timestamps_opts [type: :utc_datetime]

      import Ecto.Changeset
      import Ecto.Query
      alias Krath.Schema
    end
  end
end
