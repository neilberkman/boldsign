defmodule Boldsign.MultipartTest do
  use ExUnit.Case, async: true

  test "encode/1 keeps files separate and flattens nested objects with bracket notation" do
    pdf = "%PDF-1.4 test"

    {file_parts, field_parts} =
      Boldsign.Multipart.encode(%{
        files: [Boldsign.File.from_binary(pdf, "fsma-report.pdf", "application/pdf")],
        signers: [
          %{
            emailAddress: "qa@freshdirect.com",
            name: "QA Lead",
            signerType: "Signer"
          }
        ],
        textTagDefinitions: [
          %{definitionId: "SignHere", signerIndex: 1, type: "Signature"}
        ],
        title: "FSMA Report",
        useTextTags: true
      })

    assert file_parts == [
             {"Files", {pdf, filename: "fsma-report.pdf", content_type: "application/pdf"}}
           ]

    assert {"title", "FSMA Report"} in field_parts
    assert {"useTextTags", "true"} in field_parts

    # Signers flattened with bracket notation
    assert {"signers[0][emailAddress]", "qa@freshdirect.com"} in field_parts
    assert {"signers[0][name]", "QA Lead"} in field_parts
    assert {"signers[0][signerType]", "Signer"} in field_parts

    # Text tag definitions flattened with bracket notation
    assert {"textTagDefinitions[0][definitionId]", "SignHere"} in field_parts
    assert {"textTagDefinitions[0][signerIndex]", "1"} in field_parts
    assert {"textTagDefinitions[0][type]", "Signature"} in field_parts
  end

  test "encode/1 supports string files keys and recursive nested maps" do
    png = <<137, 80, 78, 71>>

    {file_parts, field_parts} =
      Boldsign.Multipart.encode(%{
        "files" => [Boldsign.File.from_binary(png, "proof.png", "image/png")],
        signers: [
          %{
            formFields: [
              %{
                bounds: %{x: 10, y: 20},
                id: "field_1"
              }
            ],
            name: "Alex"
          }
        ]
      })

    assert file_parts == [
             {"Files", {png, filename: "proof.png", content_type: "image/png"}}
           ]

    assert {"signers[0][name]", "Alex"} in field_parts
    assert {"signers[0][formFields][0][id]", "field_1"} in field_parts
    assert {"signers[0][formFields][0][bounds][x]", "10"} in field_parts
    assert {"signers[0][formFields][0][bounds][y]", "20"} in field_parts
  end

  test "encode/1 emits '[]' string for empty list fields" do
    {_file_parts, field_parts} =
      Boldsign.Multipart.encode(%{
        signers: [%{name: "Jane", emailAddress: "jane@example.com", formFields: []}]
      })

    assert {"signers[0][formFields]", "[]"} in field_parts,
           "empty list must encode as '[]' — BoldSign rejects the empty string as null"
  end

  test "encode_raw/1 returns a binary body and multipart content-type" do
    pdf = "%PDF-1.4 test"

    {body, content_type} =
      Boldsign.Multipart.encode_raw(%{
        files: [Boldsign.File.from_binary(pdf, "agreement.pdf", "application/pdf")],
        title: "Agreement",
        useTextTags: true
      })

    assert is_binary(body)
    assert String.starts_with?(content_type, "multipart/form-data; boundary=")
    assert body =~ "agreement.pdf"
    assert body =~ "Agreement"
    assert body =~ "true"
  end
end
