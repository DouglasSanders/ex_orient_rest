defmodule Random do
  @moduledoc false

  @doc """
  Generate a random number between the two values provided.
  Used for testing only.
  """
  def between(min, max) do
    mn = min(min, max)
    mx = max(min, max)
    :rand.uniform(mx - mn + 1) + mn - 1
  end

  @doc """
  Generate a random string from the characters a-z, A-Z, 0-9.
  Used for testing only.
  """
  def random_string(length \\ 10) do
    alphabet = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    gen_random_string(length, alphabet)
  end

  @doc """
  Generate a random rid for OrientDB.
  Used for testing only.
  """
  def rand_rid() do
    gen_random_string(4, "123456789") <> ":" <> gen_random_string(4, "123456789")
  end


  @doc """
  Generate a random string of the requested length from the characters 0-9.

  Used for testing only.
  """
  def random_number_string(length \\ 10) do
    gen_random_string(length, "0123456789")
  end

  ## PRIVATE

  defp gen_random_string(length, charset) do
    alphabet_length = charset |> String.length

    1..length
      |> Enum.map_join(
        fn(_) ->
          charset |> String.at(:rand.uniform(alphabet_length) - 1)
        end
        )
  end
end
