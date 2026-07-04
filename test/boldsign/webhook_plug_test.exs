defmodule Boldsign.WebhookPlugTest do
  use ExUnit.Case, async: true

  import Plug.Conn
  import Plug.Test

  defmodule OkHandler do
    @behaviour Boldsign.Webhook.Handler

    @impl true
    def handle_webhook(event) do
      send(self(), {:webhook, event})
      :ok
    end
  end

  defmodule ErrorHandler do
    @behaviour Boldsign.Webhook.Handler

    @impl true
    def handle_webhook(_event), do: {:error, "boom"}
  end

  @secret "test_webhook_secret"

  defp opts(handler \\ OkHandler) do
    Boldsign.WebhookPlug.init(
      at: "/webhook/boldsign",
      handler: handler,
      secret: @secret
    )
  end

  defp signed_conn(body) do
    timestamp = "1617180024"

    signature =
      :crypto.mac(:hmac, :sha256, @secret, "#{timestamp}.#{body}")
      |> Base.encode16(case: :lower)

    conn(:post, "/webhook/boldsign", body)
    |> put_req_header("x-boldsign-signature", "t=#{timestamp},s0=#{signature}")
  end

  test "acknowledges an unsigned verification ping from the X-BoldSign-Event header" do
    body = ~s({"event":{"eventType":"Verification","environment":"Test"}})

    conn =
      conn(:post, "/webhook/boldsign", body)
      |> put_req_header("x-boldsign-event", "Verification")
      |> Boldsign.WebhookPlug.call(opts())

    assert conn.halted
    assert conn.status == 200
    assert conn.resp_body == "OK"
    refute_received {:webhook, _}
  end

  test "verification header is matched case-insensitively" do
    conn =
      conn(:post, "/webhook/boldsign", "{}")
      |> put_req_header("x-boldsign-event", "VERIFICATION")
      |> Boldsign.WebhookPlug.call(opts())

    assert conn.status == 200
  end

  test "a signed event dispatches to the handler" do
    body = ~s({"event":{"eventType":"Completed"},"data":{"documentId":"doc-1"}})

    conn =
      signed_conn(body)
      |> put_req_header("x-boldsign-event", "Completed")
      |> Boldsign.WebhookPlug.call(opts())

    assert conn.halted
    assert conn.status == 200
    assert_received {:webhook, %{"event" => %{"eventType" => "Completed"}}}
  end

  test "an unsigned non-verification event is rejected with 401" do
    body = ~s({"event":{"eventType":"Completed"}})

    conn =
      conn(:post, "/webhook/boldsign", body)
      |> put_req_header("x-boldsign-event", "Completed")
      |> Boldsign.WebhookPlug.call(opts())

    assert conn.status == 401
    refute_received {:webhook, _}
  end

  test "a handler error returns 400" do
    body = ~s({"event":{"eventType":"Declined"}})

    conn =
      signed_conn(body)
      |> Boldsign.WebhookPlug.call(opts(ErrorHandler))

    assert conn.status == 400
  end

  test "other paths pass through untouched" do
    conn =
      conn(:post, "/other/path", "{}")
      |> Boldsign.WebhookPlug.call(opts())

    refute conn.halted
    assert conn.status == nil
  end
end
