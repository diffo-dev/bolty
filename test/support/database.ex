# SPDX-FileCopyrightText: 2024 bolty contributors
# SPDX-License-Identifier: Apache-2.0

defmodule Bolty.Test.Support.Database do
  def clear(conn) do
    Bolty.query!(conn, "MATCH (n) DETACH DELETE n")
  end
end
