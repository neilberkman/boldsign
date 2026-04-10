defmodule Boldsign.DocumentTest do
  use ExUnit.Case, async: true

  import Plug.Conn

  setup do
    bypass = Bypass.open()
    client = Boldsign.new(api_key: "test_key", base_url: "http://localhost:#{bypass.port}/v1")
    {:ok, bypass: bypass, client: client}
  end

  test "send/2 sends POST request", %{bypass: bypass, client: client} do
    Bypass.expect(bypass, "POST", "/v1/document/send", fn conn ->
      {:ok, body, conn} = read_body(conn)
      params = Jason.decode!(body)
      assert params["title"] == "Agreement"

      conn
      |> put_resp_content_type("application/json")
      |> send_resp(200, Jason.encode!(%{documentId: "doc_123"}))
    end)

    assert %{"documentId" => "doc_123"} = Boldsign.Document.send(client, %{title: "Agreement"})
  end

  test "list/2 sends GET request", %{bypass: bypass, client: client} do
    Bypass.expect(bypass, "GET", "/v1/document/list", fn conn ->
      assert conn.query_params["page"] == "1"

      conn
      |> put_resp_content_type("application/json")
      |> send_resp(200, Jason.encode!(%{result: []}))
    end)

    assert %{"result" => []} = Boldsign.Document.list(client, page: 1)
  end

  test "download/2 sends GET request", %{bypass: bypass, client: client} do
    Bypass.expect(bypass, "GET", "/v1/document/download", fn conn ->
      assert conn.query_params["documentId"] == "doc_123"
      send_resp(conn, 200, "PDF_CONTENT")
    end)

    assert "PDF_CONTENT" == Boldsign.Document.download(client, "doc_123")
  end

  test "revoke/3 sends POST request", %{bypass: bypass, client: client} do
    Bypass.expect(bypass, "POST", "/v1/document/revoke", fn conn ->
      assert conn.query_params["documentId"] == "doc_123"
      send_resp(conn, 204, "")
    end)

    assert "" == Boldsign.Document.revoke(client, "doc_123", %{message: "Revoked"})
  end
end
