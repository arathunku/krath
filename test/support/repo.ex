defmodule Krath.Repo do
  use Ecto.Repo, otp_app: :krath,
    adapter: Ecto.Adapters.Postgres,
    migration_timestamps: [type: :utc_datetime]

  @doc """
  Dynamically loads the repository url from the
  DATABASE_URL environment variable.
  """
  def init(_, opts) do
    opts =
      case Keyword.get(opts, :database) do
        nil ->
          Keyword.put(opts, :url, System.get_env("DATABASE_URL"))

        name ->
          opts
          |> Keyword.put(:url, System.get_env("DATABASE_URL") <> "/" <> name)
          |> Keyword.delete(:database)
      end
      |> Keyword.put(:pool_size, db_pool_size(opts))

    {:ok, opts}
  end

  def db_pool_size(opts) do
    if pool_size = System.get_env("DB_POOL_SIZE") do
      String.to_integer(pool_size)
    else
      opts[:pool_size] || 1
    end
  end
end
