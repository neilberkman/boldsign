# Boldsign Elixir Client

Unofficial Elixir client for [BoldSign](https://boldsign.com/).

Built with [Req](https://github.com/wojtekmach/req).

## Quick Start with LiveBook

**The easiest way to get started** is through our interactive LiveBook examples:

### Embedded Signing

Complete working demonstration of BoldSign embedded signing:

[![Run in Livebook](https://livebook.dev/badge/v1/blue.svg)](https://livebook.dev/run?url=https://github.com/neilberkman/boldsign/blob/main/examples/embedded_signing.livemd)

## Installation

The package can be installed by adding `boldsign` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:boldsign, "~> 0.1.0"}
  ]
end
```

## Usage

### Configuration

```elixir
client = Boldsign.new(api_key: "your_api_key")
# or for EU region
client = Boldsign.new(api_key: "your_api_key", region: :eu)
```

### Documents

#### Send a Document with Text Tags

Text tags are the best way to place fields in generated PDFs without using coordinates.

```elixir
params = %{
  title: "Agreement",
  useTextTags: true,
  textTagDefinitions: [
    %{
      definitionId: "SignHere",
      signerIndex: 1,
      type: "Signature"
    }
  ],
  signers: [%{name: "John Doe", email: "john@example.com"}]
}

Boldsign.Document.send(client, params)
```

#### List Documents

```elixir
documents = Boldsign.Document.list(client, page: 1, pageSize: 10)
```

### Templates

#### Send Document from Template

```elixir
Boldsign.Template.send(client, "template_id", %{
  roles: [%{roleIndex: 1, name: "John Doe", email: "john@example.com"}]
})
```

### Users & Teams

```elixir
users = Boldsign.User.list(client)
teams = Boldsign.Team.list(client)
```

### Webhooks

#### Verify Signature

```elixir
# In your Phoenix controller
payload = conn.assigns[:raw_body]
signature = get_req_header(conn, "x-boldsign-signature") |> List.first()
secret = "your_webhook_secret"

if Boldsign.Webhook.verify_signature(payload, signature, secret) do
  # Valid
else
  # Invalid
end
```

## Credits

This project is inspired by the [Dashbit blog post on building SDKs with Req](https://dashbit.co/blog/sdks-with-req-stripe).
Formatting and CI structure borrowed from [docusign_elixir](https://github.com/neilberkman/docusign_elixir).
Uses [Quokka](https://github.com/lucasmazza/quokka) for formatting.
