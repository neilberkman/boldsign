defmodule Boldsign.DocumentTest do
  use Boldsign.ApiCase, async: true

  test "send/2 sends JSON by default", %{server: server, client: client} do
    Boldsign.TestHTTPServer.expect(server, "POST", "/v1/document/send", fn conn ->
      {params, conn} = read_json_body(conn)

      assert get_req_header(conn, "x-api-key") == ["test_key"]
      assert params["title"] == "Agreement"

      json_response(conn, 200, %{documentId: "doc_123"})
    end)

    assert %{"documentId" => "doc_123"} = Boldsign.Document.send(client, %{title: "Agreement"})
  end

  test "send/2 sends multipart form data when files are present", %{server: server, client: client} do
    Boldsign.TestHTTPServer.expect(server, "POST", "/v1/document/send", fn conn ->
      {:ok, body, conn} = read_body(conn)
      [content_type] = get_req_header(conn, "content-type")

      assert content_type =~ "multipart/form-data"
      assert body =~ ~s(name="Files"; filename="agreement.pdf")
      assert body =~ ~s(name="signers[0][name]")
      assert body =~ "QA Lead"

      json_response(conn, 200, %{documentId: "doc_456"})
    end)

    assert %{"documentId" => "doc_456"} =
             Boldsign.Document.send(client, %{
               files: [Boldsign.File.from_binary("%PDF-1.4", "agreement.pdf", "application/pdf")],
               signers: [%{emailAddress: "qa@example.com", name: "QA Lead"}],
               title: "Agreement"
             })
  end

  test "edit/3 uses PUT and supports multipart bodies", %{server: server, client: client} do
    Boldsign.TestHTTPServer.expect(server, "PUT", "/v1/document/edit", fn conn ->
      conn = fetch_query(conn)
      {:ok, body, conn} = read_body(conn)
      [content_type] = get_req_header(conn, "content-type")

      assert conn.query_params["documentId"] == "doc_123"
      assert content_type =~ "multipart/form-data"
      assert body =~ ~s(name="Files"; filename="agreement.pdf")
      assert body =~ ~s(name="title")
      assert body =~ "Updated Agreement"

      json_response(conn, 200, %{documentId: "doc_123"})
    end)

    assert %{"documentId" => "doc_123"} =
             Boldsign.Document.edit(client, "doc_123", %{
               files: [Boldsign.File.from_binary("%PDF-1.4", "agreement.pdf", "application/pdf")],
               title: "Updated Agreement"
             })
  end

  test "edit/2 extracts documentId from params", %{server: server, client: client} do
    Boldsign.TestHTTPServer.expect(server, "PUT", "/v1/document/edit", fn conn ->
      conn = fetch_query(conn)
      {params, conn} = read_json_body(conn)

      assert conn.query_params["documentId"] == "doc_123"
      assert params["title"] == "Updated Agreement"

      json_response(conn, 200, %{documentId: "doc_123"})
    end)

    assert %{"documentId" => "doc_123"} =
             Boldsign.Document.edit(client, %{documentId: "doc_123", title: "Updated Agreement"})
  end

  test "delete/3 passes optional query params", %{server: server, client: client} do
    Boldsign.TestHTTPServer.expect(server, "DELETE", "/v1/document/delete", fn conn ->
      conn = fetch_query(conn)

      assert conn.query_params["documentId"] == "doc_123"
      assert conn.query_params["deletePermanently"] == "true"

      send_resp(conn, 204, "")
    end)

    assert "" == Boldsign.Document.delete(client, "doc_123", deletePermanently: true)
  end

  test "download/3 passes optional onBehalfOf query", %{server: server, client: client} do
    Boldsign.TestHTTPServer.expect(server, "GET", "/v1/document/download", fn conn ->
      conn = fetch_query(conn)

      assert conn.query_params["documentId"] == "doc_123"
      assert conn.query_params["onBehalfOf"] == "sender@example.com"

      send_resp(conn, 200, "PDF_CONTENT")
    end)

    assert "PDF_CONTENT" ==
             Boldsign.Document.download(client, "doc_123", onBehalfOf: "sender@example.com")
  end

  test "download_attachment/4 sends GET request", %{server: server, client: client} do
    Boldsign.TestHTTPServer.expect(server, "GET", "/v1/document/downloadAttachment", fn conn ->
      conn = fetch_query(conn)

      assert conn.query_params["documentId"] == "doc_123"
      assert conn.query_params["attachmentId"] == "att_456"
      assert conn.query_params["onBehalfOf"] == "sender@example.com"

      send_resp(conn, 200, "ATTACHMENT_CONTENT")
    end)

    assert "ATTACHMENT_CONTENT" ==
             Boldsign.Document.download_attachment(
               client,
               "doc_123",
               "att_456",
               onBehalfOf: "sender@example.com"
             )
  end

  test "download_audit_log/3 sends GET request", %{server: server, client: client} do
    Boldsign.TestHTTPServer.expect(server, "GET", "/v1/document/downloadAuditLog", fn conn ->
      conn = fetch_query(conn)

      assert conn.query_params["documentId"] == "doc_123"

      send_resp(conn, 200, "AUDIT_LOG")
    end)

    assert "AUDIT_LOG" == Boldsign.Document.download_audit_log(client, "doc_123")
  end

  test "list/2 sends GET request", %{server: server, client: client} do
    Boldsign.TestHTTPServer.expect(server, "GET", "/v1/document/list", fn conn ->
      conn = fetch_query(conn)
      assert conn.query_params["page"] == "1"
      json_response(conn, 200, %{result: []})
    end)

    assert %{"result" => []} = Boldsign.Document.list(client, page: 1)
  end

  test "team_list/2 sends GET request", %{server: server, client: client} do
    Boldsign.TestHTTPServer.expect(server, "GET", "/v1/document/teamlist", fn conn ->
      conn = fetch_query(conn)
      assert conn.query_params["TeamId"] == "team_123"
      json_response(conn, 200, %{result: []})
    end)

    assert %{"result" => []} = Boldsign.Document.team_list(client, [{"TeamId", "team_123"}])
  end

  test "behalf_list/2 sends GET request", %{server: server, client: client} do
    Boldsign.TestHTTPServer.expect(server, "GET", "/v1/document/behalfList", fn conn ->
      conn = fetch_query(conn)
      assert conn.query_params["EmailAddress"] == "sender@example.com"
      json_response(conn, 200, %{result: []})
    end)

    assert %{"result" => []} =
             Boldsign.Document.behalf_list(client, [{"EmailAddress", "sender@example.com"}])
  end

  test "revoke/3 sends POST request", %{server: server, client: client} do
    Boldsign.TestHTTPServer.expect(server, "POST", "/v1/document/revoke", fn conn ->
      conn = fetch_query(conn)
      {params, conn} = read_json_body(conn)

      assert conn.query_params["documentId"] == "doc_123"
      assert params["message"] == "Revoked"

      send_resp(conn, 204, "")
    end)

    assert "" == Boldsign.Document.revoke(client, "doc_123", %{message: "Revoked"})
  end

  test "add_authentication/3 sends PATCH request", %{server: server, client: client} do
    Boldsign.TestHTTPServer.expect(server, "PATCH", "/v1/document/addAuthentication", fn conn ->
      conn = fetch_query(conn)
      {params, conn} = read_json_body(conn)

      assert conn.query_params["documentId"] == "doc_123"
      assert params["authenticationType"] == "AccessCode"

      json_response(conn, 200, %{success: true})
    end)

    assert %{"success" => true} =
             Boldsign.Document.add_authentication(client, "doc_123", %{
               accessCode: "1234",
               authenticationType: "AccessCode"
             })
  end

  test "remove_authentication/3 uses DocumentId query casing", %{server: server, client: client} do
    Boldsign.TestHTTPServer.expect(server, "PATCH", "/v1/document/RemoveAuthentication", fn conn ->
      conn = fetch_query(conn)
      {params, conn} = read_json_body(conn)

      assert conn.query_params["DocumentId"] == "doc_123"
      assert params["emailId"] == "signer@example.com"

      json_response(conn, 200, %{success: true})
    end)

    assert %{"success" => true} =
             Boldsign.Document.remove_authentication(client, "doc_123", %{emailId: "signer@example.com"})
  end

  test "add_tags/2 and delete_tags/2 send request bodies", %{server: server, client: client} do
    Boldsign.TestHTTPServer.expect_once(server, "PATCH", "/v1/document/addTags", fn conn ->
      {params, conn} = read_json_body(conn)
      assert params["documentId"] == "doc_123"
      assert params["tags"] == ["one", "two"]
      json_response(conn, 200, %{success: true})
    end)

    assert %{"success" => true} =
             Boldsign.Document.add_tags(client, %{documentId: "doc_123", tags: ["one", "two"]})
  end

  test "delete_tags/2 sends DELETE with JSON body", %{server: server, client: client} do
    Boldsign.TestHTTPServer.expect(server, "DELETE", "/v1/document/deleteTags", fn conn ->
      {params, conn} = read_json_body(conn)
      assert params["documentId"] == "doc_123"
      assert params["tags"] == ["one"]
      json_response(conn, 200, %{success: true})
    end)

    assert %{"success" => true} =
             Boldsign.Document.delete_tags(client, %{documentId: "doc_123", tags: ["one"]})
  end

  test "change_access_code/3 splits query params from body", %{server: server, client: client} do
    Boldsign.TestHTTPServer.expect(server, "PATCH", "/v1/document/changeAccessCode", fn conn ->
      conn = fetch_query(conn)
      {params, conn} = read_json_body(conn)

      assert conn.query_params["DocumentId"] == "doc_123"
      assert conn.query_params["EmailId"] == "signer@example.com"
      assert conn.query_params["ZOrder"] == "2"
      assert params["accessCode"] == "4321"

      json_response(conn, 200, %{success: true})
    end)

    assert %{"success" => true} =
             Boldsign.Document.change_access_code(client, "doc_123", %{
               accessCode: "4321",
               emailId: "signer@example.com",
               order: 2
             })
  end

  test "change_recipient/3 sends PATCH request", %{server: server, client: client} do
    Boldsign.TestHTTPServer.expect(server, "PATCH", "/v1/document/changeRecipient", fn conn ->
      conn = fetch_query(conn)
      {params, conn} = read_json_body(conn)

      assert conn.query_params["documentId"] == "doc_123"
      assert params["newSignerName"] == "New Signer"

      json_response(conn, 200, %{success: true})
    end)

    assert %{"success" => true} =
             Boldsign.Document.change_recipient(client, "doc_123", %{
               newSignerName: "New Signer",
               reason: "Updated assignee"
             })
  end

  test "extend_expiry/3 sends PATCH request", %{server: server, client: client} do
    Boldsign.TestHTTPServer.expect(server, "PATCH", "/v1/document/extendExpiry", fn conn ->
      conn = fetch_query(conn)
      {params, conn} = read_json_body(conn)

      assert conn.query_params["documentId"] == "doc_123"
      assert params["newExpiryValue"] == 10

      json_response(conn, 200, %{success: true})
    end)

    assert %{"success" => true} =
             Boldsign.Document.extend_expiry(client, "doc_123", %{newExpiryValue: 10})
  end

  test "prefill_fields/3 sends PATCH request", %{server: server, client: client} do
    Boldsign.TestHTTPServer.expect(server, "PATCH", "/v1/document/prefillFields", fn conn ->
      conn = fetch_query(conn)
      {params, conn} = read_json_body(conn)

      assert conn.query_params["documentId"] == "doc_123"
      assert [%{"id" => "field_1", "value" => "Neil"}] = params["fields"]

      json_response(conn, 200, %{success: true})
    end)

    assert %{"success" => true} =
             Boldsign.Document.prefill_fields(client, "doc_123", %{
               fields: [%{id: "field_1", value: "Neil"}]
             })
  end

  test "draft_send/2 sends POST request without body", %{server: server, client: client} do
    Boldsign.TestHTTPServer.expect(server, "POST", "/v1/document/draftSend", fn conn ->
      conn = fetch_query(conn)
      assert conn.query_params["documentId"] == "doc_123"
      send_resp(conn, 201, "")
    end)

    assert "" == Boldsign.Document.draft_send(client, "doc_123")
  end

  test "cancel_editing/3 sends POST request with optional query params", %{server: server, client: client} do
    Boldsign.TestHTTPServer.expect(server, "POST", "/v1/document/cancelEditing", fn conn ->
      conn = fetch_query(conn)

      assert conn.query_params["documentId"] == "doc_123"
      assert conn.query_params["onBehalfOf"] == "sender@example.com"

      send_resp(conn, 200, "")
    end)

    assert "" == Boldsign.Document.cancel_editing(client, "doc_123", onBehalfOf: "sender@example.com")
  end

  test "get_embedded_sign_link/3 accepts query maps and keywords", %{server: server, client: client} do
    Boldsign.TestHTTPServer.expect(server, "GET", "/v1/document/getEmbeddedSignLink", fn conn ->
      conn = fetch_query(conn)

      assert conn.query_params["documentId"] == "doc_123"
      assert conn.query_params["SignerEmail"] == "signer@example.com"
      assert conn.query_params["RedirectUrl"] == "https://example.com"

      json_response(conn, 200, %{signLink: "https://example.com/sign"})
    end)

    assert %{"signLink" => "https://example.com/sign"} =
             Boldsign.Document.get_embedded_sign_link(client, "doc_123", %{
               "RedirectUrl" => "https://example.com",
               "SignerEmail" => "signer@example.com"
             })
  end

  test "create_embedded_edit_url/3 supports multipart bodies", %{server: server, client: client} do
    Boldsign.TestHTTPServer.expect(server, "POST", "/v1/document/createEmbeddedEditUrl", fn conn ->
      conn = fetch_query(conn)
      {:ok, body, conn} = read_body(conn)
      [content_type] = get_req_header(conn, "content-type")

      assert conn.query_params["documentId"] == "doc_123"
      assert content_type =~ "multipart/form-data"
      assert body =~ ~s(name="Files"; filename="agreement.pdf")

      json_response(conn, 200, %{url: "https://example.com/edit"})
    end)

    assert %{"url" => "https://example.com/edit"} =
             Boldsign.Document.create_embedded_edit_url(client, "doc_123", %{
               files: [Boldsign.File.from_binary("%PDF-1.4", "agreement.pdf", "application/pdf")]
             })
  end

  test "create_embedded_request_url/2 supports multipart bodies", %{server: server, client: client} do
    Boldsign.TestHTTPServer.expect(server, "POST", "/v1/document/createEmbeddedRequestUrl", fn conn ->
      {:ok, body, conn} = read_body(conn)
      [content_type] = get_req_header(conn, "content-type")

      assert content_type =~ "multipart/form-data"
      assert body =~ ~s(name="Files"; filename="agreement.pdf")

      json_response(conn, 200, %{url: "https://example.com/request"})
    end)

    assert %{"url" => "https://example.com/request"} =
             Boldsign.Document.create_embedded_request_url(client, %{
               files: [Boldsign.File.from_binary("%PDF-1.4", "agreement.pdf", "application/pdf")]
             })
  end

  test "remind/3 expands a receiverEmails list into repeated query params",
       %{server: server, client: client} do
    Boldsign.TestHTTPServer.expect(server, "POST", "/v1/document/remind", fn conn ->
      conn = fetch_query(conn)
      {params, conn} = read_json_body(conn)

      assert conn.query_params["documentId"] == "doc_123"
      # A list of emails must become repeated query params, not a single list
      # value (which Req refuses to encode). Both appear in the raw query string.
      assert conn.query_string =~ "receiverEmails=a%40x.com"
      assert conn.query_string =~ "receiverEmails=b%40x.com"
      assert params["Message"] == "nudge"

      send_resp(conn, 204, "")
    end)

    assert "" ==
             Boldsign.Document.remind(client, "doc_123", %{
               "Message" => "nudge",
               receiverEmails: ["a@x.com", "b@x.com"]
             })
  end
end
