defmodule Boldsign.WebhookPlug do
  @moduledoc """
  A `Plug` for handling BoldSign webhooks.

  This plug verifies the webhook signature and dispatches the event to a handler.

  ## Usage

  In your `endpoint.ex`, before `Plug.Parsers`:

  ```elixir
  plug Boldsign.WebhookPlug,
    at: "/webhook/boldsign",
    handler: MyApp.BoldsignHandler,
    secret: "your_webhook_secret"
  ```

  The `secret` option can also be a zero-arity function for runtime resolution:

  ```elixir
  plug Boldsign.WebhookPlug,
    at: "/webhook/boldsign",
    handler: MyApp.BoldsignHandler,
    secret: fn -> System.fetch_env!("BOLDSIGN_WEBHOOK_SECRET") end
  ```

  Your handler should implement the `Boldsign.Webhook.Handler` behavior.
  """

  @behaviour Plug

  import Plug.Conn

  def init(opts) do
    path_info = String.split(opts[:at] || "/webhook/boldsign", "/", trim: true)

    %{
      handler: opts[:handler],
      path_info: path_info,
      secret: opts[:secret]
    }
  end

  def call(%Plug.Conn{method: "POST", path_info: path_info} = conn, %{path_info: path_info} = opts) do
    # BoldSign's endpoint-verification ping (the dashboard "Verify" button and
    # webhook re-verification) is sent before any signing secret exists, so it
    # can never carry a valid signature. BoldSign's documented pattern is to
    # acknowledge it from the X-BoldSign-Event header without signature
    # validation; the ping is stateless, so accepting it unsigned is safe.
    if verification_ping?(conn) do
      send_resp(conn, 200, "OK") |> halt()
    else
      handle_event(conn, opts)
    end
  end

  def call(conn, _opts), do: conn

  defp verification_ping?(conn) do
    case get_req_header(conn, "x-boldsign-event") do
      [value | _] -> String.downcase(value) == "verification"
      [] -> false
    end
  end

  defp handle_event(conn, opts) do
    {:ok, payload, conn} = read_full_body(conn)

    signature_header =
      get_req_header(conn, "x-boldsign-signature")
      |> List.first()

    secret = get_secret(opts[:secret])

    if Boldsign.Webhook.verify_signature(payload, signature_header, secret) do
      case Jason.decode(payload) do
        {:ok, event} ->
          dispatch_event(conn, opts[:handler], event)

        {:error, _} ->
          send_resp(conn, 400, "Invalid JSON") |> halt()
      end
    else
      send_resp(conn, 401, "Invalid signature") |> halt()
    end
  end

  defp read_full_body(conn, acc \\ "") do
    case read_body(conn) do
      {:ok, body, conn} -> {:ok, acc <> body, conn}
      {:more, body, conn} -> read_full_body(conn, acc <> body)
    end
  end

  defp get_secret(fun) when is_function(fun), do: fun.()
  defp get_secret(secret), do: secret

  defp dispatch_event(conn, handler, event) do
    case handler.handle_webhook(event) do
      res when res in [:ok, {:ok, :any}] ->
        send_resp(conn, 200, "OK") |> halt()

      {:error, reason} ->
        send_resp(conn, 400, reason) |> halt()

      _ ->
        send_resp(conn, 400, "Error") |> halt()
    end
  end
end
