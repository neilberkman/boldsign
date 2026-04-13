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

  test "send/2 sends multipart form data when files are present", %{bypass: bypass, client: client} do
    Bypass.expect(bypass, "POST", "/v1/document/send", fn conn ->
      {:ok, body, conn} = read_body(conn)
      [content_type] = get_req_header(conn, "content-type")

      assert content_type =~ "multipart/form-data"
      assert body =~ ~s(name="Files"; filename="agreement.pdf")
      assert body =~ ~s(name="title")
      assert body =~ "Agreement"
      assert body =~ ~s(name="signers[0]")
      assert body =~ ~s(name="useTextTags")
      assert body =~ "true"

      [_, signer_json] = Regex.run(~r/name="signers\[0\]"\r\n\r\n([^\r\n]+)/, body)

      assert Jason.decode!(signer_json) == %{
               "emailAddress" => "qa@example.com",
               "name" => "QA Lead",
               "signerType" => "Signer"
             }

      conn
      |> put_resp_content_type("application/json")
      |> send_resp(200, Jason.encode!(%{documentId: "doc_456"}))
    end)

    assert %{"documentId" => "doc_456"} =
             Boldsign.Document.send(client, %{
               files: [
                 Boldsign.File.from_binary("%PDF-1.4", "agreement.pdf", "application/pdf")
               ],
               signers: [
                 %{
                   emailAddress: "qa@example.com",
                   name: "QA Lead",
                   signerType: "Signer"
                 }
               ],
               title: "Agreement",
               useTextTags: true
             })
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
