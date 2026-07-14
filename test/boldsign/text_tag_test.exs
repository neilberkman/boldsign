defmodule Boldsign.TextTagTest do
  use ExUnit.Case, async: true

  alias Boldsign.TextTag

  test "signature/2 builds a Signature definition with default size" do
    assert TextTag.signature("sign_here", signer_index: 2) == %{
             definitionId: "sign_here",
             signerIndex: 2,
             size: %{width: 220, height: 50},
             type: "Signature"
           }
  end

  test "date_signed/2 defaults signer_index to 1 and uses the DateSigned type" do
    assert TextTag.date_signed(:date_here) == %{
             definitionId: "date_here",
             signerIndex: 1,
             size: %{width: 120, height: 24},
             type: "DateSigned"
           }
  end

  test "size override accepts a map or a tuple" do
    assert TextTag.signature("s", size: %{width: 300, height: 60}).size == %{width: 300, height: 60}
    assert TextTag.signature("s", size: {300, 60}).size == %{width: 300, height: 60}
  end

  test "text_box, initial, checkbox map to their BoldSign type strings" do
    assert TextTag.text_box("t").type == "TextBox"
    assert TextTag.initial("i").type == "Initial"
    assert TextTag.checkbox("c").type == "CheckBox"
  end

  test "build/3 is the escape hatch for any type" do
    assert TextTag.build("Company", "co", signer_index: 1).type == "Company"
  end
end
