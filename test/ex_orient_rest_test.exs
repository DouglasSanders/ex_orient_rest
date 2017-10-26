defmodule ExOrientRestTest do
  use ExUnit.Case
  doctest ExOrientRest

  test "greets the world" do
    assert ExOrientRest.hello() == :world
  end
end
