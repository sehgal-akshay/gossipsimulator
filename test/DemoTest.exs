defmodule DemoTest do
  use ExUnit.Case

  doctest MainController

  test "greets the world" do
    MainController.ProcessController.start 2
  end
end