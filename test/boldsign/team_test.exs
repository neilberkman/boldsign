defmodule Boldsign.TeamTest do
  use Boldsign.ApiCase, async: true

  test "list/2 sends GET request", %{server: server, client: client} do
    Boldsign.TestHTTPServer.expect(server, "GET", "/v1/teams/list", fn conn ->
      conn = fetch_query(conn)
      assert conn.query_params["Page"] == "1"
      json_response(conn, 200, %{result: []})
    end)

    assert %{"result" => []} = Boldsign.Team.list(client, [{"Page", 1}])
  end

  test "get/2 sends GET request", %{server: server, client: client} do
    Boldsign.TestHTTPServer.expect(server, "GET", "/v1/teams/get", fn conn ->
      conn = fetch_query(conn)
      assert conn.query_params["teamId"] == "team_123"
      json_response(conn, 200, %{teamId: "team_123"})
    end)

    assert %{"teamId" => "team_123"} = Boldsign.Team.get(client, "team_123")
  end

  test "create/2 sends POST request", %{server: server, client: client} do
    Boldsign.TestHTTPServer.expect(server, "POST", "/v1/teams/create", fn conn ->
      {params, conn} = read_json_body(conn)
      assert params["teamName"] == "Legal"
      json_response(conn, 201, %{teamId: "team_123"})
    end)

    assert %{"teamId" => "team_123"} = Boldsign.Team.create(client, %{teamName: "Legal"})
  end

  test "update/2 uses PUT", %{server: server, client: client} do
    Boldsign.TestHTTPServer.expect(server, "PUT", "/v1/teams/update", fn conn ->
      {params, conn} = read_json_body(conn)
      assert params["teamId"] == "team_123"
      assert params["teamName"] == "Finance"
      json_response(conn, 200, %{teamId: "team_123"})
    end)

    assert %{"teamId" => "team_123"} =
             Boldsign.Team.update(client, %{teamId: "team_123", teamName: "Finance"})
  end
end
