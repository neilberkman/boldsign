defmodule Boldsign.ContactGroupTest do
  use Boldsign.ApiCase, async: true

  test "list/2 sends GET request", %{server: server, client: client} do
    Boldsign.TestHTTPServer.expect(server, "GET", "/v1/contactGroups/list", fn conn ->
      conn = fetch_query(conn)
      assert conn.query_params["Page"] == "1"
      json_response(conn, 200, %{result: []})
    end)

    assert %{"result" => []} = Boldsign.ContactGroup.list(client, [{"Page", 1}])
  end

  test "get/2 sends GET request", %{server: server, client: client} do
    Boldsign.TestHTTPServer.expect(server, "GET", "/v1/contactGroups/get", fn conn ->
      conn = fetch_query(conn)
      assert conn.query_params["groupId"] == "group_123"
      json_response(conn, 200, %{groupId: "group_123"})
    end)

    assert %{"groupId" => "group_123"} = Boldsign.ContactGroup.get(client, "group_123")
  end

  test "create/2 sends POST request", %{server: server, client: client} do
    Boldsign.TestHTTPServer.expect(server, "POST", "/v1/contactGroups/create", fn conn ->
      {params, conn} = read_json_body(conn)
      assert params["groupName"] == "Finance"
      json_response(conn, 200, %{groupId: "group_123"})
    end)

    assert %{"groupId" => "group_123"} =
             Boldsign.ContactGroup.create(client, %{groupName: "Finance"})
  end

  test "update/3 sends PUT request", %{server: server, client: client} do
    Boldsign.TestHTTPServer.expect(server, "PUT", "/v1/contactGroups/update", fn conn ->
      conn = fetch_query(conn)
      {params, conn} = read_json_body(conn)

      assert conn.query_params["groupId"] == "group_123"
      assert params["groupName"] == "Legal"

      json_response(conn, 200, %{groupId: "group_123"})
    end)

    assert %{"groupId" => "group_123"} =
             Boldsign.ContactGroup.update(client, "group_123", %{groupName: "Legal"})
  end

  test "delete/2 sends DELETE request", %{server: server, client: client} do
    Boldsign.TestHTTPServer.expect(server, "DELETE", "/v1/contactGroups/delete", fn conn ->
      conn = fetch_query(conn)
      assert conn.query_params["groupId"] == "group_123"
      send_resp(conn, 204, "")
    end)

    assert "" == Boldsign.ContactGroup.delete(client, "group_123")
  end
end
