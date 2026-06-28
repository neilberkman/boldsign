defmodule Boldsign.ContactTest do
  use Boldsign.ApiCase, async: true

  test "list/2 sends GET request", %{bypass: bypass, client: client} do
    Bypass.expect(bypass, "GET", "/v1/contacts/list", fn conn ->
      conn = fetch_query(conn)
      assert conn.query_params["Page"] == "1"
      json_response(conn, 200, %{result: []})
    end)

    assert %{"result" => []} = Boldsign.Contact.list(client, [{"Page", 1}])
  end

  test "get/2 sends GET request", %{bypass: bypass, client: client} do
    Bypass.expect(bypass, "GET", "/v1/contacts/get", fn conn ->
      conn = fetch_query(conn)
      assert conn.query_params["id"] == "contact_123"
      json_response(conn, 200, %{id: "contact_123"})
    end)

    assert %{"id" => "contact_123"} = Boldsign.Contact.get(client, "contact_123")
  end

  test "create/2 sends POST request", %{bypass: bypass, client: client} do
    Bypass.expect(bypass, "POST", "/v1/contacts/create", fn conn ->
      {params, conn} = read_json_body(conn)
      assert [%{"email" => "john@example.com", "name" => "John"}] = params
      json_response(conn, 200, %{createdContacts: [%{id: "contact_123"}]})
    end)

    assert %{"createdContacts" => [%{"id" => "contact_123"}]} =
             Boldsign.Contact.create(client, [%{email: "john@example.com", name: "John"}])
  end

  test "update/3 sends PUT request", %{bypass: bypass, client: client} do
    Bypass.expect(bypass, "PUT", "/v1/contacts/update", fn conn ->
      conn = fetch_query(conn)
      {params, conn} = read_json_body(conn)

      assert conn.query_params["id"] == "contact_123"
      assert params["name"] == "Jane"

      json_response(conn, 200, %{id: "contact_123"})
    end)

    assert %{"id" => "contact_123"} =
             Boldsign.Contact.update(client, "contact_123", %{name: "Jane"})
  end

  test "delete/2 sends DELETE request", %{bypass: bypass, client: client} do
    Bypass.expect(bypass, "DELETE", "/v1/contacts/delete", fn conn ->
      conn = fetch_query(conn)
      assert conn.query_params["id"] == "contact_123"
      send_resp(conn, 204, "")
    end)

    assert "" == Boldsign.Contact.delete(client, "contact_123")
  end
end
