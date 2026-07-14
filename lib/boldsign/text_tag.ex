defmodule Boldsign.TextTag do
  @moduledoc """
  Typed builders for BoldSign text-tag form-field definitions.

  BoldSign can place form fields from *text tags*: put a `{{definition_id}}`
  placeholder in the document, then send a matching `textTagDefinitions` entry
  (with `useTextTags: true`) so BoldSign replaces the placeholder with a typed
  field. This module builds those entries so callers do not have to hand-write
  the field-type strings (`"Signature"`, `"DateSigned"`, ...) or the payload
  shape.

  ## Example

      pdf # ...contains "{{sign_here}}" and "{{date_here}}"

      Boldsign.Document.send(client, %{
        title: "Agreement",
        files: [Boldsign.File.from_binary(pdf, "agreement.pdf", "application/pdf")],
        signers: [%{name: "Ada", emailAddress: "ada@example.com", signerType: "Signer"}],
        useTextTags: true,
        textTagDefinitions: [
          Boldsign.TextTag.signature("sign_here", signer_index: 1),
          Boldsign.TextTag.date_signed("date_here", signer_index: 1)
        ]
      })

  Each `definition_id` must appear verbatim in the document as `{{definition_id}}`.
  """

  @default_sizes %{
    "Signature" => %{width: 220, height: 50},
    "Initial" => %{width: 80, height: 50},
    "DateSigned" => %{width: 120, height: 24},
    "TextBox" => %{width: 180, height: 24},
    "CheckBox" => %{width: 24, height: 24}
  }

  @typedoc "Options: `:signer_index` (1-based, default 1) and `:size` (`%{width:, height:}` or `{w, h}`)."
  @type opts :: [signer_index: pos_integer(), size: map() | {number(), number()}]

  @doc "A signature field anchored at the `{{definition_id}}` placeholder."
  @spec signature(String.t() | atom(), opts()) :: map()
  def signature(definition_id, opts \\ []), do: build("Signature", definition_id, opts)

  @doc "An initials field."
  @spec initial(String.t() | atom(), opts()) :: map()
  def initial(definition_id, opts \\ []), do: build("Initial", definition_id, opts)

  @doc "A date-signed field (auto-filled by BoldSign with the signing date)."
  @spec date_signed(String.t() | atom(), opts()) :: map()
  def date_signed(definition_id, opts \\ []), do: build("DateSigned", definition_id, opts)

  @doc "A free-text field the signer fills in."
  @spec text_box(String.t() | atom(), opts()) :: map()
  def text_box(definition_id, opts \\ []), do: build("TextBox", definition_id, opts)

  @doc "A checkbox field."
  @spec checkbox(String.t() | atom(), opts()) :: map()
  def checkbox(definition_id, opts \\ []), do: build("CheckBox", definition_id, opts)

  @doc """
  Builds a definition for any BoldSign field `type` string. Use the typed
  helpers above for the common cases; this is the escape hatch for others.
  """
  @spec build(String.t(), String.t() | atom(), opts()) :: map()
  def build(type, definition_id, opts \\ []) when is_binary(type) do
    size = Keyword.get(opts, :size) || Map.get(@default_sizes, type, %{width: 120, height: 24})

    %{
      definitionId: to_string(definition_id),
      signerIndex: Keyword.get(opts, :signer_index, 1),
      size: normalize_size(size),
      type: type
    }
  end

  defp normalize_size(%{width: w, height: h}), do: %{width: w, height: h}
  defp normalize_size(%{"width" => w, "height" => h}), do: %{width: w, height: h}
  defp normalize_size({w, h}), do: %{width: w, height: h}
end
