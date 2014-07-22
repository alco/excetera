defmodule DiamorfosiTest.MiscTest do
  use ExUnit.Case

  import DiamorfosiTest.Helpers

  setup_all do
    cleanup("/misc_test")
  end

  setup do
    on_exit fn -> cleanup("/misc_test") end
  end

  test "waiting" do
    pid = self()

    spawn_link(fn ->
      send(pid, {:done_waiting, Diamorfosi.fetch!("/misc_test/a", wait: true)})
    end)
    refute_receive _

    :ok = Diamorfosi.set "/misc_test/a", "1"
    assert_receive {:done_waiting, "1"}
  end

  test "get and fetch timeout" do
    # TODO: investigate hackney timeouts
  end

  test "set timeout" do
    # TODO: investigate hackney timeouts
  end

  test "wait timeout" do
    # TODO: investigate hackney timeouts
    #Application.put_env(:diamorfosi, :timeout, 10)

    #pid = self()
    #spawn_link(fn ->
    #  send(pid, {:done_waiting, Diamorfosi.fetch!("/misc_test/w", wait: true)})
    #end)
    #:timer.sleep(100)
    #refute_receive _

    #:ok = Diamorfosi.set("/misc_test/w", "tadam!")
    #assert_receive {:done_waiting, "tadam!"}
  after
    :application.unset_env(:diamorfosi, :timeout)
  end

  test "wait explicit timeout" do
    #pid = self()
    #spawn_link(fn ->
    #  send(pid, {:done_waiting, Diamorfosi.fetch("/misc_test/w", wait: true, timeout: 10)})
    #end)
    #refute_receive _
    #:timer.sleep(100)
    #assert_receive {:done_waiting, {:error, "Timeout"}}
  end

  test "compare and swap" do
    assert {:error, "Key not found"} = Diamorfosi.set("/misc_test/a", "1", condition: [prevExist: true])
    assert :ok = Diamorfosi.set("/misc_test/a", "1", condition: [prevExist: false])
    assert {:error, "Key already exists"} = Diamorfosi.set("/misc_test/a", "2", condition: [prevExist: false])
    assert {:error, "Compare failed"} = Diamorfosi.set("/misc_test/a", "2", condition: [prevValue: "2"])
    assert :ok = Diamorfosi.set("/misc_test/a", "2", condition: [prevValue: "1"])
  end

  test "compare and delete" do
    :ok = Diamorfosi.set("/misc_test/a/b", "1")
    assert {:error, "Not a file"} = Diamorfosi.delete("/misc_test/a", condition: [prevValue: "1"])
    assert {:error, "Compare failed"} = Diamorfosi.delete("/misc_test/a/b", condition: [prevValue: "2"])
    assert :ok = Diamorfosi.delete("/misc_test/a/b", condition: [prevValue: "1"])
    assert {:error, "Key not found"} = Diamorfosi.fetch("/misc_test/a/b")
  end

  @tag :slowpoke
  test "setting with TTL" do
    :ok = Diamorfosi.set "/crud_test_ttl", "valuex", [ttl: 1]
    :timer.sleep 1500
    assert Diamorfosi.get("/crud_test_ttl", false) == false
  end

  @tag :slowpoke
  test "directory ttl" do
    :ok = Diamorfosi.mkdir("/api_test/a", [ttl: 1])
    assert {:ok, key1} = Diamorfosi.put("/api_test/a", "1")
    assert "1" = Diamorfosi.fetch!("/api_test/a/#{key1}")
    :timer.sleep(1500)
    assert {:error, "Key not found"} = Diamorfosi.fetch("/api_test/a/#{key1}")
    assert {:error, "Key not found"} = Diamorfosi.fetch("/api_test/a")
  end
end
