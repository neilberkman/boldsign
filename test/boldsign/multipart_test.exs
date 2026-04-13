defmodule Boldsign.MultipartTest do
  use ExUnit.Case, async: true

  test "encode/1 keeps files separate and JSON-encodes complex list items" do
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

    assert {"signers[0]", signer_json} =
             Enum.find(field_parts, fn {key, _value} -> key == "signers[0]" end)

    assert Jason.decode!(signer_json) == %{
             "emailAddress" => "qa@freshdirect.com",
             "name" => "QA Lead",
             "signerType" => "Signer"
           }

    assert {"textTagDefinitions[0]", text_tag_json} =
             Enum.find(field_parts, fn {key, _value} -> key == "textTagDefinitions[0]" end)

    assert Jason.decode!(text_tag_json) == %{
             "definitionId" => "SignHere",
             "signerIndex" => 1,
             "type" => "Signature"
           }
  end
end
