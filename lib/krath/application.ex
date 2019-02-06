defmodule Krath.Application do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    Confex.resolve_env!(:krath)

    children = if Code.ensure_loaded?(Krath.Repo) do
      [
        supervisor(Krath.Repo, [])
      ]
    else
      []
    end

    opts = [strategy: :one_for_one, name: Krath.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
