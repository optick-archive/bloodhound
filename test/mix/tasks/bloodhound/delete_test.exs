defmodule Bloodhound.DeleteTest do
  use ExUnit.Case

  alias Bloodhound.Client
  alias Mix.Tasks.Bloodhound.Delete
  alias Bloodhound.ExampleModel

  setup do
    Client.delete

    :ok
  end

  test "all documents can be deleted" do
    Client.index "test", %{id: 1, message: "All Falls Down"}
    Client.index "example", %{id: 2, message: "Can't Tell Me Nothing"}
    Delete.run([])
    assert {:error, %{status_code: 404}} = Client.get "test", 5
    assert {:error, %{status_code: 404}} = Client.get "example", 2
  end

  test "all documents of a type can be deleted" do
    Client.index "test", %{id: 2, message: "All of the Lights"}
    ExampleModel.index %ExampleModel{id: 1, message: "Through the Wire"}
    Delete.run(["Bloodhound.ExampleModel"])
    assert {:ok, document} = Client.get "test", 2
    assert document.message === "All of the Lights"
    assert {:error, %{status_code: 404}} = ExampleModel.get_index 1
  end

  test "a model's index can be deleted" do
    ExampleModel.index %ExampleModel{id: 2, message: "Lampshades On Fire"}
    Delete.run(["Bloodhound.ExampleModel", "2"])
    assert {:error, %{status_code: 404}} = ExampleModel.get_index 2
  end
end