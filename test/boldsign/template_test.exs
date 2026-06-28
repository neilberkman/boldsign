defmodule Boldsign.TemplateTest do
  use Boldsign.ApiCase, async: true

  test "list/2 sends GET request", %{bypass: bypass, client: client} do
    Bypass.expect(bypass, "GET", "/v1/template/list", fn conn ->
      conn = fetch_query(conn)
      assert conn.query_params["page"] == "1"
      json_response(conn, 200, %{result: []})
    end)

    assert %{"result" => []} = Boldsign.Template.list(client, page: 1)
  end

  test "create/2 supports multipart requests", %{bypass: bypass, client: client} do
    Bypass.expect(bypass, "POST", "/v1/template/create", fn conn ->
      {:ok, body, conn} = read_body(conn)
      [content_type] = get_req_header(conn, "content-type")

      assert content_type =~ "multipart/form-data"
      assert body =~ ~s(name="Files"; filename="template.pdf")
      assert body =~ ~s(name="title")
      assert body =~ "Offer Letter"

      json_response(conn, 201, %{templateId: "tpl_123"})
    end)

    assert %{"templateId" => "tpl_123"} =
             Boldsign.Template.create(client, %{
               files: [Boldsign.File.from_binary("%PDF-1.4", "template.pdf", "application/pdf")],
               title: "Offer Letter"
             })
  end

  test "send/3 supports multipart requests", %{bypass: bypass, client: client} do
    Bypass.expect(bypass, "POST", "/v1/template/send", fn conn ->
      conn = fetch_query(conn)
      {:ok, body, conn} = read_body(conn)
      [content_type] = get_req_header(conn, "content-type")

      assert conn.query_params["templateId"] == "tpl_123"
      assert content_type =~ "multipart/form-data"
      assert body =~ ~s(name="Files"; filename="template.pdf")

      json_response(conn, 201, %{documentId: "doc_123"})
    end)

    assert %{"documentId" => "doc_123"} =
             Boldsign.Template.send(client, "tpl_123", %{
               files: [Boldsign.File.from_binary("%PDF-1.4", "template.pdf", "application/pdf")]
             })
  end

  test "edit/3 uses PUT", %{bypass: bypass, client: client} do
    Bypass.expect(bypass, "PUT", "/v1/template/edit", fn conn ->
      conn = fetch_query(conn)
      {params, conn} = read_json_body(conn)

      assert conn.query_params["templateId"] == "tpl_123"
      assert params["title"] == "Updated Template"

      json_response(conn, 200, %{templateId: "tpl_123"})
    end)

    assert %{"templateId" => "tpl_123"} =
             Boldsign.Template.edit(client, "tpl_123", %{title: "Updated Template"})
  end

  test "delete/3 passes optional query params", %{bypass: bypass, client: client} do
    Bypass.expect(bypass, "DELETE", "/v1/template/delete", fn conn ->
      conn = fetch_query(conn)

      assert conn.query_params["templateId"] == "tpl_123"
      assert conn.query_params["onBehalfOf"] == "sender@example.com"

      send_resp(conn, 204, "")
    end)

    assert "" == Boldsign.Template.delete(client, "tpl_123", onBehalfOf: "sender@example.com")
  end

  test "download/3 passes optional query params", %{bypass: bypass, client: client} do
    Bypass.expect(bypass, "GET", "/v1/template/download", fn conn ->
      conn = fetch_query(conn)

      assert conn.query_params["templateId"] == "tpl_123"
      assert conn.query_params["includeFormFieldValues"] == "true"

      send_resp(conn, 200, "PDF_CONTENT")
    end)

    assert "PDF_CONTENT" ==
             Boldsign.Template.download(client, "tpl_123", includeFormFieldValues: true)
  end

  test "get_properties/2 sends GET request", %{bypass: bypass, client: client} do
    Bypass.expect(bypass, "GET", "/v1/template/properties", fn conn ->
      conn = fetch_query(conn)
      assert conn.query_params["templateId"] == "tpl_123"
      json_response(conn, 200, %{templateId: "tpl_123"})
    end)

    assert %{"templateId" => "tpl_123"} = Boldsign.Template.get_properties(client, "tpl_123")
  end

  test "add_tags/2 and delete_tags/2 send bodies", %{bypass: bypass, client: client} do
    Bypass.expect_once(bypass, "PATCH", "/v1/template/addTags", fn conn ->
      {params, conn} = read_json_body(conn)
      assert params["templateId"] == "tpl_123"
      assert params["templateLabels"] == ["nda"]
      json_response(conn, 200, %{success: true})
    end)

    assert %{"success" => true} =
             Boldsign.Template.add_tags(client, %{templateId: "tpl_123", templateLabels: ["nda"]})
  end

  test "delete_tags/2 sends DELETE with body", %{bypass: bypass, client: client} do
    Bypass.expect(bypass, "DELETE", "/v1/template/deleteTags", fn conn ->
      {params, conn} = read_json_body(conn)
      assert params["templateId"] == "tpl_123"
      assert params["templateLabels"] == ["nda"]
      json_response(conn, 200, %{success: true})
    end)

    assert %{"success" => true} =
             Boldsign.Template.delete_tags(client, %{templateId: "tpl_123", templateLabels: ["nda"]})
  end

  test "create_embedded_request_url/3 supports multipart requests", %{bypass: bypass, client: client} do
    Bypass.expect(bypass, "POST", "/v1/template/createEmbeddedRequestUrl", fn conn ->
      conn = fetch_query(conn)
      {:ok, body, conn} = read_body(conn)
      [content_type] = get_req_header(conn, "content-type")

      assert conn.query_params["templateId"] == "tpl_123"
      assert content_type =~ "multipart/form-data"
      assert body =~ ~s(name="Files"; filename="template.pdf")

      json_response(conn, 200, %{url: "https://example.com/request"})
    end)

    assert %{"url" => "https://example.com/request"} =
             Boldsign.Template.create_embedded_request_url(client, "tpl_123", %{
               files: [Boldsign.File.from_binary("%PDF-1.4", "template.pdf", "application/pdf")]
             })
  end

  test "create_embedded_template_url/2 supports multipart requests", %{bypass: bypass, client: client} do
    Bypass.expect(bypass, "POST", "/v1/template/createEmbeddedTemplateUrl", fn conn ->
      {:ok, body, conn} = read_body(conn)
      [content_type] = get_req_header(conn, "content-type")

      assert content_type =~ "multipart/form-data"
      assert body =~ ~s(name="Files"; filename="template.pdf")

      json_response(conn, 201, %{url: "https://example.com/template"})
    end)

    assert %{"url" => "https://example.com/template"} =
             Boldsign.Template.create_embedded_template_url(client, %{
               files: [Boldsign.File.from_binary("%PDF-1.4", "template.pdf", "application/pdf")]
             })
  end

  test "get_embedded_template_edit_url/3 sends request", %{bypass: bypass, client: client} do
    Bypass.expect(bypass, "POST", "/v1/template/getEmbeddedTemplateEditUrl", fn conn ->
      conn = fetch_query(conn)
      {params, conn} = read_json_body(conn)

      assert conn.query_params["templateId"] == "tpl_123"
      assert params["redirectUrl"] == "https://example.com"

      json_response(conn, 200, %{url: "https://example.com/edit"})
    end)

    assert %{"url" => "https://example.com/edit"} =
             Boldsign.Template.get_embedded_template_edit_url(client, "tpl_123", %{
               redirectUrl: "https://example.com"
             })
  end

  test "create_embedded_preview_url/3 sends request", %{bypass: bypass, client: client} do
    Bypass.expect(bypass, "POST", "/v1/template/createEmbeddedPreviewUrl", fn conn ->
      conn = fetch_query(conn)
      {params, conn} = read_json_body(conn)

      assert conn.query_params["templateId"] == "tpl_123"
      assert params["showToolbar"] == true

      json_response(conn, 200, %{url: "https://example.com/preview"})
    end)

    assert %{"url" => "https://example.com/preview"} =
             Boldsign.Template.create_embedded_preview_url(client, "tpl_123", %{showToolbar: true})
  end

  test "merge_and_send/2 supports multipart requests", %{bypass: bypass, client: client} do
    Bypass.expect(bypass, "POST", "/v1/template/mergeAndSend", fn conn ->
      {:ok, body, conn} = read_body(conn)
      [content_type] = get_req_header(conn, "content-type")

      assert content_type =~ "multipart/form-data"
      assert body =~ ~s(name="Files"; filename="template.pdf")

      json_response(conn, 201, %{documentId: "doc_123"})
    end)

    assert %{"documentId" => "doc_123"} =
             Boldsign.Template.merge_and_send(client, %{
               files: [Boldsign.File.from_binary("%PDF-1.4", "template.pdf", "application/pdf")]
             })
  end

  test "merge_create_embedded_request_url/2 supports multipart requests", %{
    bypass: bypass,
    client: client
  } do
    Bypass.expect(bypass, "POST", "/v1/template/mergeCreateEmbeddedRequestUrl", fn conn ->
      {:ok, body, conn} = read_body(conn)
      [content_type] = get_req_header(conn, "content-type")

      assert content_type =~ "multipart/form-data"
      assert body =~ ~s(name="Files"; filename="template.pdf")

      json_response(conn, 201, %{url: "https://example.com/merge"})
    end)

    assert %{"url" => "https://example.com/merge"} =
             Boldsign.Template.merge_create_embedded_request_url(client, %{
               files: [Boldsign.File.from_binary("%PDF-1.4", "template.pdf", "application/pdf")]
             })
  end
end
