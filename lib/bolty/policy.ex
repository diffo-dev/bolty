defmodule Bolty.Policy do
  @moduledoc """
  Resolved driver behaviour for a single connection.

  Produced once at HELLO completion by `Bolty.Policy.Resolver`, stashed on the
  connection state, and threaded into every pack/unpack call. Codecs
  pattern-match on policy fields and never read a Bolt or server version
  directly.

  Policy is an internal distillation of negotiated facts, not a user-facing
  configuration surface. Users influence policy by passing connection options
  (e.g. constraining `:versions` at negotiation); the resolver responds
  accordingly.

  See `.agent-notes/policy-design.md` for the authoritative design.
  """

  @typedoc """
  DateTime encoding dialect.

    * `:legacy` — emit legacy struct tags (0x46 for DateTime-with-offset, 0x66
      for DateTime-with-zone-id). Required for Bolt 4.x wire, regardless of
      the server's own version.
    * `:evolved` — emit evolved struct tags (0x49, 0x69). Required for Bolt
      5.x wire.
  """
  @type datetime :: :legacy | :evolved

  @type t :: %__MODULE__{
          datetime: datetime()
        }

  defstruct datetime: :legacy
end
