defmodule Boldsign.TemplateTest do
  use ExUnit.Case, async: true

  import Plug.Conn

  setup do
    bypass = Bypass.open()
    client = Boldsign.new(api_key: "test_key", base_url: "http://localhost:#{bypass.port}/v1")
    {:ok, bypass: bypass, client: client}
  end

  test "list/2 sends GET request", %{bypass: bypass, client: client} do
    Bypass.expect(bypass, "GET", "/v1/template/list", fn conn ->
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(200, Jason.encode!(%{result: []}))
    end)

    assert %{"result" => []} = Boldsign.Template.list(client)
  end

  test "send/3 sends POST request", %{bypass: bypass, client: client} do
    Bypass.expect(bypass, "POST", "/v1/template/send", fn conn ->
      assert conn.query_params["templateId"] == "tpl_123"

      conn
      |> put_resp_content_type("application/json")
      |> send_resp(200, Jason.encode!(%{documentId: "doc_123"}))
    end)

    assert %{"documentId" => "doc_123"} = Boldsign.Template.send(client, "tpl_123", %{})
  end
end
