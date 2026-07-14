defmodule Boldsign.FormField do
  @moduledoc """
  Typed builders for BoldSign signer form fields placed by coordinate.

  These build the entries you put in a signer's `formFields` list on
  `Boldsign.Document.send/2` (and friends), anchoring each field at explicit
  page coordinates.

  ## The `type` gotcha

  BoldSign's form-field object keys the field type as **`type`**, not
  `fieldType`. If you send `fieldType`, BoldSign silently ignores it and every
  field **defaults to a signature field** — so a date field renders as a second
  signature, a checkbox becomes a signature, etc., with no error. These builders
  always emit the correct `type` key so you cannot hit that trap.

  ## Coordinates

  `bounds` are in **96-DPI pixels from the top-left of the page**. If you derive
  positions from a PDF text layer (`pdftotext -bbox` reports points at 72 DPI),
  multiply by `4/3`.

  ## Example

      Boldsign.Document.send(client, %{
        title: "Agreement",
        files: [Boldsign.File.from_binary(pdf, "agreement.pdf", "application/pdf")],
        signers: [
          %{
            name: "Ada",
            emailAddress: "ada@example.com",
            signerType: "Signer",
            signerOrder: 1,
            formFields: [
              Boldsign.FormField.signature(%{x: 72, y: 803, width: 150, height: 40}, id: "sig1"),
              Boldsign.FormField.date_signed(%{x: 72, y: 889, width: 120, height: 24}, id: "date1")
            ]
          }
        ]
      })

  Prefer this coordinate path over `Boldsign.TextTag`: definition-based text tags
  on `document/send` did not reliably persist a document in live testing (the API
  returns `201` with a `documentId`, but the document is never created). See
  `Boldsign.TextTag` for details.
  """

  @typedoc "`%{x:, y:, width:, height:}` (any key style) or a `{x, y, width, height}` tuple, in 96-DPI px from the top-left."
  @type bounds :: map() | {number(), number(), number(), number()}

  @typedoc "Options: `:page` (1-based, default 1), `:required` (default `true`), `:id`, `:name`."
  @type opts :: [page: pos_integer(), required: boolean(), id: String.t(), name: String.t()]

  @doc "A signature field."
  @spec signature(bounds(), opts()) :: map()
  def signature(bounds, opts \\ []), do: build("Signature", bounds, opts)

  @doc "An initials field."
  @spec initial(bounds(), opts()) :: map()
  def initial(bounds, opts \\ []), do: build("Initial", bounds, opts)

  @doc "A date-signed field (BoldSign auto-fills it with the signing date)."
  @spec date_signed(bounds(), opts()) :: map()
  def date_signed(bounds, opts \\ []), do: build("DateSigned", bounds, opts)

  @doc "A free-text field the signer fills in."
  @spec text_box(bounds(), opts()) :: map()
  def text_box(bounds, opts \\ []), do: build("TextBox", bounds, opts)

  @doc "A checkbox field."
  @spec checkbox(bounds(), opts()) :: map()
  def checkbox(bounds, opts \\ []), do: build("CheckBox", bounds, opts)

  @doc """
  Builds a field for any BoldSign `type` string. Use the typed helpers above for
  the common cases; this is the escape hatch for others.
  """
  @spec build(String.t(), bounds(), opts()) :: map()
  def build(type, bounds, opts \\ []) when is_binary(type) do
    %{
      type: type,
      pageNumber: Keyword.get(opts, :page, 1),
      isRequired: Keyword.get(opts, :required, true),
      bounds: normalize_bounds(bounds)
    }
    |> maybe_put(:id, Keyword.get(opts, :id))
    |> maybe_put(:name, Keyword.get(opts, :name))
  end

  defp normalize_bounds({x, y, w, h}), do: %{x: x, y: y, width: w, height: h}
  defp normalize_bounds(%{x: x, y: y, width: w, height: h}), do: %{x: x, y: y, width: w, height: h}

  defp normalize_bounds(%{"x" => x, "y" => y, "width" => w, "height" => h}), do: %{x: x, y: y, width: w, height: h}

  defp maybe_put(map, _key, nil), do: map
  defp maybe_put(map, key, value), do: Map.put(map, key, value)
end
