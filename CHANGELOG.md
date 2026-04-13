# Changelog

All notable changes to this project will be documented in this file.

## [0.5.2] - 2026-04-12

### Fixed
- Send document requests now stay on JSON by default and only switch to multipart when `files` are actually present.
- Multipart form encoding now follows the official BoldSign SDK pattern for file uploads plus JSON-encoded complex fields such as `signers` and `textTagDefinitions`.

## [0.5.0] - 2026-04-10

### Added
- Initial release with support for BoldSign REST API.
- `Boldsign` module for client configuration.
- `Boldsign.Document` for document management (send, create, list, download, etc.).
- `Boldsign.Template` for template-based operations.
- `Boldsign.User` and `Boldsign.Team` for administrative operations.
- `Boldsign.Brand` for brand management.
- `Boldsign.SenderIdentity` for sender identity management.
- `Boldsign.IdentityVerification` for KYC/identity verification flows.
- `Boldsign.Webhook` with signature verification.
- `Boldsign.WebhookPlug` and `Boldsign.Webhook.Handler` for easy Phoenix integration.
- `Boldsign.File` helper for multipart uploads.
- Livebook example for embedded signing.
