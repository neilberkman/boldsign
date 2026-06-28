defmodule Boldsign.ClientTest do
  use ExUnit.Case, async: true

  test "new/1 with api_key" do
    client = Boldsign.new(api_key: "abc")

    assert client.options.base_url == "https://api.boldsign.com/v1"
    assert ["abc"] == Req.Request.get_header(client, "x-api-key")
    assert [] == Req.Request.get_header(client, "authorization")
  end

  test "new/1 with access_token" do
    client = Boldsign.new(access_token: "token_123")

    assert client.options.base_url == "https://api.boldsign.com/v1"
    assert ["Bearer token_123"] == Req.Request.get_header(client, "authorization")
    assert [] == Req.Request.get_header(client, "x-api-key")
  end

  test "new/1 with api_key and access_token" do
    client = Boldsign.new(api_key: "abc", access_token: "token_123")

    assert ["abc"] == Req.Request.get_header(client, "x-api-key")
    assert ["Bearer token_123"] == Req.Request.get_header(client, "authorization")
  end

  test "new/1 with eu region" do
    client = Boldsign.new(api_key: "abc", region: :eu)
    assert client.options.base_url == "https://eu-api.boldsign.com/v1"
  end

  test "new/1 with ca region" do
    client = Boldsign.new(api_key: "abc", region: :ca)
    assert client.options.base_url == "https://ca-api.boldsign.com/v1"
  end

  test "new/1 with au region" do
    client = Boldsign.new(api_key: "abc", region: :au)
    assert client.options.base_url == "https://au-api.boldsign.com/v1"
  end

  test "new/1 requires credentials" do
    assert_raise ArgumentError, ":api_key or :access_token is required", fn ->
      Boldsign.new([])
    end
  end

  test "new/1 with custom base_url" do
    client = Boldsign.new(api_key: "abc", base_url: "https://example.com")
    assert client.options.base_url == "https://example.com"
  end
end
