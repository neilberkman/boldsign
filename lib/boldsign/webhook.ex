defmodule Boldsign.Webhook do
  @moduledoc """
  Webhook signature verification for BoldSign.

  BoldSign webhooks are configured exclusively via the BoldSign dashboard
  (Settings > Webhooks). There is no API for managing webhooks programmatically.

  This module provides signature verification so your application can confirm
  that incoming webhook payloads genuinely originated from BoldSign.

  ## Signature format

  BoldSign sends a signature header (`x-boldsign-signature`) in the format:

      t=UNIX_TIMESTAMP,s0=HEX_SIGNATURE

  The signature is an HMAC-SHA256 of `TIMESTAMP.RAW_BODY` using the webhook
  secret from your BoldSign dashboard.
  """

  @doc """
  Verifies a BoldSign webhook signature.

  Parses the `t=TIMESTAMP,s0=SIGNATURE` header, computes the expected
  HMAC-SHA256 of `TIMESTAMP.RAW_BODY`, and compares against the provided
  hex-encoded signature using constant-time comparison.

  Returns `true` if the signature is valid, `false` otherwise.

  ## Parameters

    * `raw_body` - The raw request body as a binary string
    * `signature_header` - The value of the `x-boldsign-signature` header
    * `secret` - Your webhook secret from the BoldSign dashboard

  ## Example

      signature_header = "t=1617180024,s0=6a2e..."
      Boldsign.Webhook.verify_signature(raw_body, signature_header, secret)
  """
  def verify_signature(_raw_body, nil, _secret), do: false
  def verify_signature(_raw_body, _signature_header, nil), do: false

  def verify_signature(raw_body, signature_header, secret) do
    parts =
      signature_header
      |> String.split(",")
      |> Enum.map(&String.split(&1, "=", parts: 2))
      |> Enum.filter(&match?([_, _], &1))
      |> Map.new(fn [k, v] -> {k, v} end)

    case parts do
      %{"s0" => signature, "t" => timestamp} ->
        payload = "#{timestamp}.#{raw_body}"

        expected =
          :crypto.mac(:hmac, :sha256, secret, payload)
          |> Base.encode16(case: :lower)

        Plug.Crypto.secure_compare(expected, signature)

      _ ->
        false
    end
  end
end
