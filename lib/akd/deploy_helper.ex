defmodule Akd.DeployHelper do
  @moduledoc """
  This module defines helper functions used to initialize a deployment
  and add hooks to a deployment, and execute it.
  """

  alias Akd.{Deployment, Hook}

  # @supported_hooks ~w(stopapp startapp migratedb prebuild)a
  @native_types ~w(fetch build publish)a

  def init_deployment(opts), do: struct(Deployment, opts)

  def add_hook(deployment, exec_dest, type, mod, opts \\ []) when type in @native_types do
    add_hook(deployment, exec_dest, commands(type, mod, deployment, opts))
  end

  @doc """
  This function runs a command on a given environment of deployment.
  The command can be either an atom (if it is supported) or a string
  of bash commands.
  """
  def add_hook(%Deployment{hooks: hooks} = deployment, exec_dest, commands) do
    hooks = hooks ++ [%Hook{commands: commands, exec_dest: exec_dest}]
    %Deployment{deployment | hooks: hooks}
  end

  def exec(%Deployment{hooks: hooks}), do: Enum.each(hooks, &Hook.exec(&1))

  defp commands(:fetch, :default, d, opts), do: commands(nil, Akd.fetcher(), d, opts)
  defp commands(:build, :default, d, opts), do: commands(nil, Akd.builder(), d, opts)
  defp commands(:publish, :default, d, opts), do: commands(nil, Akd.publisher(), d, opts)
  defp commands(_type, mod, d, opts), do: apply(mod, :commands, [d, opts])

  # defp get_cmds(deployment, :stopapp), do: "bin/#{deployment.appname} stop"
  # defp get_cmds(deployment, :startapp), do: "bin/#{deployment.appname} start"
  # defp get_cmds(deployment, :migrateapp), do: "bin/#{deployment.appname} migrate"
  # defp get_cmds(_, :prebuild_phoenix), do: "mix phoenix.digest"
  # defp get_cmds(_, :prebuild) do
  #   """
  #   mix local.hex --force
  #   mix local.rebar --force
  #   mix deps.get
  #   mix deps.compile
  #   """
  # end
end
