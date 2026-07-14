defmodule Boldsign.FormFieldTest do
  use ExUnit.Case, async: true

  alias Boldsign.FormField

  test "signature/2 emits the `type` key (not fieldType) with defaults" do
    field = FormField.signature(%{x: 72, y: 803, width: 150, height: 40})

    assert field == %{
             type: "Signature",
             pageNumber: 1,
             isRequired: true,
             bounds: %{x: 72, y: 803, width: 150, height: 40}
           }

    refute Map.has_key?(field, :fieldType)
  end

  test "date_signed/2 uses the DateSigned type" do
    assert FormField.date_signed(%{x: 0, y: 0, width: 120, height: 24}).type == "DateSigned"
  end

  test "initial, text_box, checkbox map to their BoldSign type strings" do
    b = {0, 0, 10, 10}
    assert FormField.initial(b).type == "Initial"
    assert FormField.text_box(b).type == "TextBox"
    assert FormField.checkbox(b).type == "CheckBox"
  end

  test "bounds accept a tuple or string-keyed map" do
    assert FormField.signature({1, 2, 3, 4}).bounds == %{x: 1, y: 2, width: 3, height: 4}

    assert FormField.signature(%{"x" => 1, "y" => 2, "width" => 3, "height" => 4}).bounds ==
             %{x: 1, y: 2, width: 3, height: 4}
  end

  test "opts set page, required, id, and name; omitted id/name are absent" do
    field = FormField.signature({0, 0, 1, 1}, page: 2, required: false, id: "sig1", name: "sig1")
    assert field.pageNumber == 2
    assert field.isRequired == false
    assert field.id == "sig1"
    assert field.name == "sig1"

    bare = FormField.signature({0, 0, 1, 1})
    refute Map.has_key?(bare, :id)
    refute Map.has_key?(bare, :name)
  end

  test "build/3 is the escape hatch for any type" do
    assert FormField.build("Email", {0, 0, 1, 1}).type == "Email"
  end
end
