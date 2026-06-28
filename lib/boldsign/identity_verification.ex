defmodule Boldsign.IdentityVerification do
  @moduledoc """
  BoldSign Identity Verification API.
  """

  @doc """
  Creates an embedded verification URL.
  """
  def create_embedded_verification_url(client, params) when is_map(params) or is_list(params) do
    {document_id, body} =
      Boldsign.Request.pop_required_query_param(params, "documentId", [:documentId, "documentId"])

    create_embedded_verification_url(client, document_id, body)
  end

  def create_embedded_verification_url(client, document_id, params) do
    Boldsign.Request.request!(
      client,
      :post,
      "/identityVerification/createEmbeddedVerificationUrl",
      query: [documentId: document_id],
      body: params
    )
  end

  @doc """
  Gets an identity verification report.
  """
  def get_report(client, document_id, params \\ %{}) do
    Boldsign.Request.request!(
      client,
      :post,
      "/identityVerification/report",
      query: [documentId: document_id],
      body: params
    )
  end

  @doc """
  Gets an identity verification image.
  """
  def get_image(client, document_id, params) when is_map(params) or is_list(params) do
    Boldsign.Request.request!(
      client,
      :post,
      "/identityVerification/image",
      query: [documentId: document_id],
      body: params
    )
  end

  def get_image(client, document_id, file_id) when is_binary(file_id) do
    get_image(client, document_id, %{fileId: file_id})
  end
end
