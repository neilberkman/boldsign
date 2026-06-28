[![Hex.pm](https://img.shields.io/hexpm/v/boldsign)](https://hex.pm/packages/boldsign)
[![Hexdocs.pm](https://img.shields.io/badge/docs-hexdocs.pm-blue)](https://hexdocs.pm/boldsign)
[![GitHub Actions](https://github.com/neilberkman/boldsign/actions/workflows/elixir.yml/badge.svg)](https://github.com/neilberkman/boldsign/actions/workflows/elixir.yml)

# Boldsign Elixir Client

Unofficial Elixir client for [BoldSign](https://boldsign.com/) built on top of [Req](https://github.com/wojtekmach/req).

Use it to send documents for signature, generate embedded signing links, manage templates and users, work with contacts and custom fields, verify webhooks, and plug BoldSign into Phoenix apps without dragging in a huge SDK.

## Why This Library

- Supports both `X-API-KEY` and OAuth bearer token auth.
- Covers the most useful BoldSign API areas in a lightweight, idiomatic Elixir wrapper.
- Automatically switches between JSON and multipart requests when file uploads are present.
- Includes Phoenix-friendly webhook verification helpers.
- Ships with broad Bypass-backed test coverage so wrappers stay honest.

## Quick Start with LiveBook

The fastest way to try the client is the interactive LiveBook example:

[![Run in Livebook](https://livebook.dev/badge/v1/blue.svg)](https://livebook.dev/run?url=https://github.com/neilberkman/boldsign/blob/main/examples/embedded_signing.livemd)

## Installation

Add `boldsign` to your dependencies:

```elixir
def deps do
  [
    {:boldsign, "~> 0.7.0"}
  ]
end
```

The docs are available at [hexdocs.pm/boldsign](https://hexdocs.pm/boldsign).

## Authentication

Boldsign supports either API keys or OAuth access tokens:

```elixir
# API key
client = Boldsign.new(api_key: "your_api_key")

# OAuth bearer token
oauth_client = Boldsign.new(access_token: "your_oauth_access_token")

# Dual credential setup if your app may use either path
hybrid_client = Boldsign.new(
  api_key: "your_api_key",
  access_token: "your_oauth_access_token"
)
```

Regional base URLs are built in:

```elixir
Boldsign.new(api_key: "your_api_key", region: :us)
Boldsign.new(api_key: "your_api_key", region: :eu)
Boldsign.new(api_key: "your_api_key", region: :ca)
Boldsign.new(api_key: "your_api_key", region: :au)
```

If you need a custom endpoint, pass `base_url: ...` directly.

## Quick Examples

### Send a document

```elixir
params = %{
  title: "Agreement",
  message: "Please review and sign.",
  fileUrls: ["https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf"],
  signers: [
    %{
      name: "John Doe",
      emailAddress: "john@example.com",
      signerOrder: 1
    }
  ]
}

Boldsign.Document.send(client, params)
```

### Generate an embedded signing link

```elixir
response = Boldsign.Document.get_embedded_sign_link(client, "document_id", %{
  "SignerEmail" => "john@example.com",
  "RedirectUrl" => "https://example.com/complete"
})

response["signLink"]
```

### Send from a template

```elixir
Boldsign.Template.send(client, "template_id", %{
  roles: [
    %{
      roleIndex: 1,
      name: "John Doe",
      emailAddress: "john@example.com"
    }
  ]
})
```

### Update user metadata

```elixir
Boldsign.User.update_metadata(client, %{
  userId: "user_id",
  metaData: %{department: "Legal", cost_center: "A-14"}
})
```

### Verify webhooks

```elixir
payload = conn.assigns[:raw_body]
signature = get_req_header(conn, "x-boldsign-signature") |> List.first()
secret = System.fetch_env!("BOLDSIGN_WEBHOOK_SECRET")

Boldsign.Webhook.verify_signature(payload, signature, secret)
```

## API Coverage

### Core APIs

- `Boldsign.Document`
- `Boldsign.Template`
- `Boldsign.Brand`
- `Boldsign.SenderIdentity`
- `Boldsign.IdentityVerification`
- `Boldsign.User`
- `Boldsign.Team`

### Directory and admin APIs

- `Boldsign.Contact`
- `Boldsign.ContactGroup`
- `Boldsign.CustomField`
- `Boldsign.Plan`

### Support modules

- `Boldsign.File`
- `Boldsign.Multipart`
- `Boldsign.Webhook`
- `Boldsign.WebhookPlug`

## Notes on Params

This client intentionally stays thin. Most list and filter options are forwarded directly to BoldSign, so use the official request parameter names when a given endpoint expects a specific casing such as `Page`, `TeamId`, `SignerEmail`, or `RedirectUrl`.

For endpoints that support file uploads, pass `files: [...]` using `Boldsign.File.from_path/1` or `Boldsign.File.from_binary/3` and the client will transparently switch to multipart form data.

```elixir
Boldsign.Document.send(client, %{
  title: "NDA",
  files: [Boldsign.File.from_path("/tmp/nda.pdf")],
  signers: [%{name: "Jane", emailAddress: "jane@example.com"}]
})
```

## Phoenix Integration

Use the included plug if you want webhook verification and dispatch in one place:

```elixir
plug Boldsign.WebhookPlug,
  at: "/webhook/boldsign",
  handler: MyApp.BoldsignHandler,
  secret: fn -> System.fetch_env!("BOLDSIGN_WEBHOOK_SECRET") end
```

Your handler just needs to implement `Boldsign.Webhook.Handler`.

## Development

```bash
mix format
mix test
```

The test suite uses Bypass and exercises the request shapes for auth, multipart uploads, documents, templates, contacts, contact groups, custom fields, users, teams, identity verification, and plan APIs.

## Credits

This project is inspired by the [Dashbit blog post on building SDKs with Req](https://dashbit.co/blog/sdks-with-req-stripe).

Formatting and CI structure were adapted from [docusign_elixir](https://github.com/neilberkman/docusign_elixir).
