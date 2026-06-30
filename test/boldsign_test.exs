defmodule BoldsignTest do
  use ExUnit.Case, async: true

  import Plug.Conn

  setup do
    server = Boldsign.TestHTTPServer.open()
    client = Boldsign.new(api_key: "test_key", base_url: "http://localhost:#{server.port}/v1")
    {:ok, server: server, client: client}
  end

  test "Boldsign.Document.send/2", %{server: server, client: client} do
    Boldsign.TestHTTPServer.expect(server, "POST", "/v1/document/send", fn conn ->
      {:ok, body, conn} = read_body(conn)
      params = Jason.decode!(body)

      assert get_req_header(conn, "x-api-key") == ["test_key"]
      assert params["title"] == "Agreement"

      conn
      |> put_resp_content_type("application/json")
      |> send_resp(200, Jason.encode!(%{documentId: "doc_123"}))
    end)

    response = Boldsign.Document.send(client, %{title: "Agreement"})
    assert response["documentId"] == "doc_123"
  end
end
