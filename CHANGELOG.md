# Changelog

All notable changes to this project will be documented in this file.

## [0.8.0] - 2026-06-30

### Changed
- Bumped the package version to `0.8.0`.
- Replaced Bypass-backed tests with a small Bandit-backed local test server.
- Multipart uploads now use raw request bodies to avoid creating atoms from dynamic BoldSign form field names.

### Fixed
- Empty multipart list fields now encode as `"[]"` instead of being omitted.
- Multipart field names and filenames now percent-escape `"`, CR, and LF in content disposition headers.
- Webhook signature parsing now handles BoldSign headers with a space after the comma, such as `t=TIMESTAMP, s0=SIGNATURE`.

### Tests
- Added regression coverage for empty list multipart encoding, raw multipart request encoding, multipart content disposition escaping, and spaced webhook signature headers.

## [0.7.0] - 2026-06-28

### Added
- OAuth bearer token support via `Boldsign.new(access_token: ...)`.
- New `Boldsign.Contact`, `Boldsign.ContactGroup`, `Boldsign.CustomField`, and `Boldsign.Plan` modules.
- Additional document endpoints for attachments, audit logs, tags, recipient authentication, recipient changes, expiry updates, prefill updates, team/behalf lists, and draft sending.
- Additional template endpoints for tags, embedded request/create/edit URLs, and embedded merge request URLs.
- `Boldsign.User.update_metadata/2`.

### Changed
- Bumped the package version to `0.7.0`.
- Refreshed the README and LiveBook embedded signing example for the current API surface, current regional endpoints, API-key or OAuth auth, and hosted-PDF usage.
- Expanded request handling so document and template operations can automatically switch between JSON and multipart payloads where the official BoldSign API allows file uploads.
- Updated the default regional base URLs to match the current official BoldSign endpoints, including CA and AU regions.

### Fixed
- Added compatibility with `req` 0.6 by converting multipart form-part names to atoms at the request boundary while preserving the exact BoldSign wire field names.
- Corrected several HTTP verb and query-parameter mismatches in existing document, template, team, user, and identity verification wrappers.
- Aligned identity verification requests with the current official API contract.

### Tests
- Added extensive local HTTP server coverage across client auth, documents, templates, contacts, contact groups, custom fields, users, teams, identity verification, plan APIs, and multipart encoding.
- Added multipart regression coverage for Req-compatible atom part names, including bracketed/dotted BoldSign field names.

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
