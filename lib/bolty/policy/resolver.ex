# SPDX-FileCopyrightText: 2024 bolty contributors
# SPDX-License-Identifier: Apache-2.0

defmodule Bolty.Policy.Resolver do
  @moduledoc false

  alias Bolty.Policy

  @doc """
  Resolve a `%Bolty.Policy{}` from the negotiated Bolt version and the HELLO
  response metadata.

  Pure function — no I/O, no process calls, no globals. Safe to call in tests
  against synthetic inputs.

  `server_metadata` is the raw map returned by HELLO (keys are strings:
  `"server"`, `"hints"`, `"connection_id"`, etc.). We extract what we need
  and thread both `bolt_version` and `server_version` into every
  per-dimension decision so that adding a server_version branch later is a
  clause change, not a signature change.
  """
  @spec resolve(float() | nil, map()) :: Policy.t()
  def resolve(bolt_version, server_metadata) when is_map(server_metadata) do
    server_version = Map.get(server_metadata, "server")

    %Policy{}
    |> put_datetime(bolt_version, server_version)

    # |> put_vectors(bolt_version, server_version)  # issue #13
  end

  # Working hypothesis, to be calibrated against the docker-compose matrix:
  # bolt_version alone discriminates the three scenarios we care about for
  # datetime, and server_version is not actually consulted.
  #
  #   Neo4j 4.x x Bolt 4.x  -> :legacy    (legacy tags over legacy wire)
  #   Neo4j 5.x x Bolt 4.x  -> :legacy    (legacy wire still requires legacy tags)
  #   Neo4j 5.x x Bolt 5.x  -> :evolved   (evolved wire, evolved tags)
  #
  # A 4.x server never negotiates Bolt 5.x, so that combination is unreachable.
  #
  # Two realistic ways this could be wrong (resolvable via the matrix):
  #   - Scenario 2 (Neo4j 5.x speaking Bolt 4.x) may not accept the same
  #     legacy tags that Neo4j 4.x accepts -> add a server_version branch.
  #   - Memgraph advertises `server: "Neo4j/5.2.0"` but its Bolt 5.x datetime
  #     handling may diverge -> add a server_version branch on scenario 3.
  #
  # Both facts are named here so adding such a branch is clause-local.
  defp put_datetime(policy, bolt_version, _server_version)
       when is_float(bolt_version) and bolt_version >= 5.0 do
    %{policy | datetime: :evolved}
  end

  defp put_datetime(policy, _bolt_version, _server_version), do: policy
end
