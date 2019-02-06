use Mix.Config

config :logger, level: :warn

config :krath, Krath.Repo,
  username: "postgres",
  password: "postgres",
  database: "mintdoors_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
