defmodule Boldsign.Webhook do
  @moduledoc """
  BoldSign Webhook API.
  """

  @doc """
  Lists webhooks.
  """
  def list(client) do
    Req.get!(client, url: "/webhook/list").body
  end

  @doc """
  Creates a new webhook.
  """
  def create(client, params) do
    Req.post!(client, url: "/webhook/create", json: params).body
  end

  @doc """
  Updates a webhook.
  """
  def update(client, params) do
    Req.post!(client, url: "/webhook/update", json: params).body
  end

  @doc """
  Deletes a webhook.
  """
  def delete(client, webhook_id) do
    Req.delete!(client, url: "/webhook/delete", params: [webhookId: webhook_id]).body
  end

  @doc """
  Verifies a webhook signature.

  ## Example

      Boldsign.Webhook.verify_signature(payload, signature, secret)
  """
  def verify_signature(payload, signature, secret) do
    computed_signature =
      :crypto.mac(:hmac, :sha256, secret, payload)
      |> Base.encode64()

    Plug.Crypto.secure_compare(computed_signature, signature)
  end
end
