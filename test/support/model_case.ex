defmodule Flux.ModelCase do
  @moduledoc """
  This module defines the flux case to be used by
  model fluxs.

  You may define functions here to be used as helpers in
  your model fluxs. See `errors_on/2`'s definition as reference.

  Finally, if the flux case interacts with the database,
  it cannot be async. For this reason, every flux runs
  inside a transaction which is reset at the beginning
  of the flux unless the flux case is marked as async.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      alias Flux.Repo

      import Ecto
      import Ecto.Changeset
      import Ecto.Query
      import Flux.ModelCase
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Flux.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(Flux.Repo, {:shared, self()})
    end

    :ok
  end

  @doc """
  Helper for returning list of errors in a struct when given certain data.

  ## Examples

  Given a User schema that lists `:name` as a required field and validates
  `:password` to be safe, it would return:

      iex> errors_on(%User{}, %{password: "password"})
      [password: "is unsafe", name: "is blank"]

  You could then write your assertion like:

      assert {:password, "is unsafe"} in errors_on(%User{}, %{password: "password"})
  """
  def errors_on(struct, data) do
    struct.__struct__.changeset(struct, data)
    |> Ecto.Changeset.traverse_errors(&Flux.ErrorHelpers.translate_error/1)
    |> Enum.flat_map(fn {key, errors} -> for msg <- errors, do: {key, msg} end)
  end
end
