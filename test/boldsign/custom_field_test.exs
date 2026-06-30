defmodule Boldsign.CustomFieldTest do
  use Boldsign.ApiCase, async: true

  test "create/2 sends POST request", %{server: server, client: client} do
    Boldsign.TestHTTPServer.expect(server, "POST", "/v1/customField/create", fn conn ->
      {params, conn} = read_json_body(conn)
      assert params["fieldName"] == "Department"
      json_response(conn, 200, %{customFieldId: "field_123"})
    end)

    assert %{"customFieldId" => "field_123"} =
             Boldsign.CustomField.create(client, %{fieldName: "Department"})
  end

  test "edit/3 sends POST request", %{server: server, client: client} do
    Boldsign.TestHTTPServer.expect(server, "POST", "/v1/customField/edit", fn conn ->
      conn = fetch_query(conn)
      {params, conn} = read_json_body(conn)

      assert conn.query_params["customFieldId"] == "field_123"
      assert params["fieldName"] == "Cost Center"

      json_response(conn, 200, %{customFieldId: "field_123"})
    end)

    assert %{"customFieldId" => "field_123"} =
             Boldsign.CustomField.edit(client, "field_123", %{fieldName: "Cost Center"})
  end

  test "delete/2 sends DELETE request", %{server: server, client: client} do
    Boldsign.TestHTTPServer.expect(server, "DELETE", "/v1/customField/delete", fn conn ->
      conn = fetch_query(conn)
      assert conn.query_params["customFieldId"] == "field_123"
      json_response(conn, 200, %{success: true})
    end)

    assert %{"success" => true} = Boldsign.CustomField.delete(client, "field_123")
  end

  test "list/2 sends GET request", %{server: server, client: client} do
    Boldsign.TestHTTPServer.expect(server, "GET", "/v1/customField/list", fn conn ->
      conn = fetch_query(conn)
      assert conn.query_params["brandId"] == "brand_123"
      json_response(conn, 200, %{result: []})
    end)

    assert %{"result" => []} = Boldsign.CustomField.list(client, "brand_123")
  end

  test "create_embedded_url/3 sends POST request with BrandId casing", %{
    server: server,
    client: client
  } do
    Boldsign.TestHTTPServer.expect(server, "POST", "/v1/customField/createEmbeddedCustomFieldUrl", fn conn ->
      conn = fetch_query(conn)

      assert conn.query_params["BrandId"] == "brand_123"
      assert conn.query_params["LinkValidTill"] == "2026-04-20T00:00:00Z"

      json_response(conn, 200, %{url: "https://example.com/custom-fields"})
    end)

    assert %{"url" => "https://example.com/custom-fields"} =
             Boldsign.CustomField.create_embedded_url(client, "brand_123", [
               {"LinkValidTill", "2026-04-20T00:00:00Z"}
             ])
  end
end
