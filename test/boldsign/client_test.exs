defmodule Boldsign.ClientTest do
  use ExUnit.Case, async: true

  test "new/1 with api_key" do
    client = Boldsign.new(api_key: "abc")
    assert client.options.base_url == "https://api.boldsign.com/v1"
    assert ["abc"] == Req.Request.get_header(client, "x-api-key")
  end

  test "new/1 with eu region" do
    client = Boldsign.new(api_key: "abc", region: :eu)
    assert client.options.base_url == "https://api-eu.boldsign.com/v1"
  end

  test "new/1 requires api_key" do
    assert_raise ArgumentError, ":api_key is required", fn ->
      Boldsign.new([])
    end
  end

  test "new/1 with custom base_url" do
    client = Boldsign.new(api_key: "abc", base_url: "https://example.com")
    assert client.options.base_url == "https://example.com"
  end
end
