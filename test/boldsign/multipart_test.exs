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
end
