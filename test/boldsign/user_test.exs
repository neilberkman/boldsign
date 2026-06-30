defmodule Boldsign.UserTest do
  use Boldsign.ApiCase, async: true

  test "list/2 sends GET request", %{server: server, client: client} do
    Boldsign.TestHTTPServer.expect(server, "GET", "/v1/users/list", fn conn ->
      conn = fetch_query(conn)
      assert conn.query_params["Page"] == "1"
      json_response(conn, 200, %{result: []})
    end)

    assert %{"result" => []} = Boldsign.User.list(client, [{"Page", 1}])
  end

  test "get/2 sends GET request", %{server: server, client: client} do
    Boldsign.TestHTTPServer.expect(server, "GET", "/v1/users/get", fn conn ->
      conn = fetch_query(conn)
      assert conn.query_params["userId"] == "user_123"
      json_response(conn, 200, %{userId: "user_123"})
    end)

    assert %{"userId" => "user_123"} = Boldsign.User.get(client, "user_123")
  end

  test "create/2 sends POST request", %{server: server, client: client} do
    Boldsign.TestHTTPServer.expect(server, "POST", "/v1/users/create", fn conn ->
      {params, conn} = read_json_body(conn)
      assert [%{"emailId" => "jane@example.com"}] = params
      send_resp(conn, 201, "")
    end)

    assert "" == Boldsign.User.create(client, [%{emailId: "jane@example.com"}])
  end

  test "update/2 uses PUT", %{server: server, client: client} do
    Boldsign.TestHTTPServer.expect(server, "PUT", "/v1/users/update", fn conn ->
      {params, conn} = read_json_body(conn)
      assert params["userId"] == "user_123"
      send_resp(conn, 200, "")
    end)

    assert "" == Boldsign.User.update(client, %{userId: "user_123"})
  end

  test "change_team/2 extracts userId from params", %{server: server, client: client} do
    Boldsign.TestHTTPServer.expect(server, "PUT", "/v1/users/changeTeam", fn conn ->
      conn = fetch_query(conn)
      {params, conn} = read_json_body(conn)

      assert conn.query_params["userId"] == "user_123"
      assert params["toTeamId"] == "team_456"

      send_resp(conn, 200, "")
    end)

    assert "" == Boldsign.User.change_team(client, %{toTeamId: "team_456", userId: "user_123"})
  end

  test "update_metadata/2 uses PUT", %{server: server, client: client} do
    Boldsign.TestHTTPServer.expect(server, "PUT", "/v1/users/updateMetaData", fn conn ->
      {params, conn} = read_json_body(conn)
      assert params["userId"] == "user_123"
      assert params["metaData"] == %{"department" => "Legal"}
      send_resp(conn, 200, "")
    end)

    assert "" ==
             Boldsign.User.update_metadata(client, %{
               metaData: %{department: "Legal"},
               userId: "user_123"
             })
  end

  test "resend_invitation/2 uses UserId query casing", %{server: server, client: client} do
    Boldsign.TestHTTPServer.expect(server, "POST", "/v1/users/resendInvitation", fn conn ->
      conn = fetch_query(conn)
      assert conn.query_params["UserId"] == "user_123"
      send_resp(conn, 200, "")
    end)

    assert "" == Boldsign.User.resend_invitation(client, "user_123")
  end

  test "cancel_invitation/2 uses UserId query casing", %{server: server, client: client} do
    Boldsign.TestHTTPServer.expect(server, "POST", "/v1/users/cancelInvitation", fn conn ->
      conn = fetch_query(conn)
      assert conn.query_params["UserId"] == "user_123"
      send_resp(conn, 200, "")
    end)

    assert "" == Boldsign.User.cancel_invitation(client, "user_123")
  end
end
