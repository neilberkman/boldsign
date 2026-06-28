defmodule Boldsign.IdentityVerificationTest do
  use Boldsign.ApiCase, async: true

  test "create_embedded_verification_url/2 extracts documentId from params", %{
    bypass: bypass,
    client: client
  } do
    Bypass.expect(bypass, "POST", "/v1/identityVerification/createEmbeddedVerificationUrl", fn conn ->
      conn = fetch_query(conn)
      {params, conn} = read_json_body(conn)

      assert conn.query_params["documentId"] == "doc_123"
      assert params["emailId"] == "signer@example.com"

      json_response(conn, 200, %{url: "https://example.com/verify"})
    end)

    assert %{"url" => "https://example.com/verify"} =
             Boldsign.IdentityVerification.create_embedded_verification_url(client, %{
               documentId: "doc_123",
               emailId: "signer@example.com"
             })
  end

  test "get_report/3 uses POST with query and body", %{bypass: bypass, client: client} do
    Bypass.expect(bypass, "POST", "/v1/identityVerification/report", fn conn ->
      conn = fetch_query(conn)
      {params, conn} = read_json_body(conn)

      assert conn.query_params["documentId"] == "doc_123"
      assert params["emailId"] == "signer@example.com"

      json_response(conn, 200, %{status: "verified"})
    end)

    assert %{"status" => "verified"} =
             Boldsign.IdentityVerification.get_report(client, "doc_123", %{
               emailId: "signer@example.com"
             })
  end

  test "get_image/3 uses POST with query and body", %{bypass: bypass, client: client} do
    Bypass.expect(bypass, "POST", "/v1/identityVerification/image", fn conn ->
      conn = fetch_query(conn)
      {params, conn} = read_json_body(conn)

      assert conn.query_params["documentId"] == "doc_123"
      assert params["fileId"] == "file_456"

      send_resp(conn, 200, "IMAGE_CONTENT")
    end)

    assert "IMAGE_CONTENT" ==
             Boldsign.IdentityVerification.get_image(client, "doc_123", %{fileId: "file_456"})
  end

  test "get_image/3 accepts file id shortcut", %{bypass: bypass, client: client} do
    Bypass.expect(bypass, "POST", "/v1/identityVerification/image", fn conn ->
      conn = fetch_query(conn)
      {params, conn} = read_json_body(conn)

      assert conn.query_params["documentId"] == "doc_123"
      assert params["fileId"] == "file_456"

      send_resp(conn, 200, "IMAGE_CONTENT")
    end)

    assert "IMAGE_CONTENT" ==
             Boldsign.IdentityVerification.get_image(client, "doc_123", "file_456")
  end
end
