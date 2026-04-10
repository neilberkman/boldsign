defmodule Boldsign.WebhookTest do
  use ExUnit.Case, async: true

  test "verify_signature/3 returns true for valid signature" do
    payload = "payload_content"
    secret = "my_secret"

    # Compute signature: Base64(HMAC-SHA256(secret, payload))
    signature =
      :crypto.mac(:hmac, :sha256, secret, payload)
      |> Base.encode64()

    assert Boldsign.Webhook.verify_signature(payload, signature, secret)
  end

  test "verify_signature/3 returns false for invalid signature" do
    refute Boldsign.Webhook.verify_signature("payload", "invalid_signature", "secret")
  end
end
