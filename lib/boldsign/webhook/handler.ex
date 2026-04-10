defmodule Boldsign.Webhook.Handler do
  @moduledoc """
  Behavior for BoldSign webhook handlers.
  """

  @callback handle_webhook(payload :: map()) :: :ok | {:ok, any()} | :error | {:error, String.t()}
end
