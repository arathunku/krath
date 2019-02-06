ExUnit.start()
ExUnit.configure(stacktrace_depth: 10)

Ecto.Adapters.SQL.Sandbox.mode(Krath.Repo, :manual)
{:ok, _} = Application.ensure_all_started(:krath)
