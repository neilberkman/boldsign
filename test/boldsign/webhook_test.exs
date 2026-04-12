defmodule Boldsign.WebhookTest do
  use ExUnit.Case, async: true

  test "verify_signature/3 returns true for valid signature" do
    raw_body = ~s({"event":"DocumentCompleted","documentId":"abc123"})
    secret = "my_webhook_secret"
    timestamp = "1617180024"

    # Compute signature: hex(HMAC-SHA256(secret, "TIMESTAMP.RAW_BODY"))
    signature =
      :crypto.mac(:hmac, :sha256, secret, "#{timestamp}.#{raw_body}")
      |> Base.encode16(case: :lower)

    header = "t=#{timestamp},s0=#{signature}"

    assert Boldsign.Webhook.verify_signature(raw_body, header, secret)
  end

  test "verify_signature/3 returns false for invalid signature" do
    header = "t=1617180024,s0=deadbeef"
    refute Boldsign.Webhook.verify_signature("payload", header, "secret")
  end

  test "verify_signature/3 returns false for nil header" do
    refute Boldsign.Webhook.verify_signature("payload", nil, "secret")
  end

  test "verify_signature/3 returns false for nil secret" do
    refute Boldsign.Webhook.verify_signature("payload", "t=123,s0=abc", nil)
  end

  test "verify_signature/3 returns false for malformed header" do
    refute Boldsign.Webhook.verify_signature("payload", "garbage", "secret")
  end
end
