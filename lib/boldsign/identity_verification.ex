defmodule Boldsign.IdentityVerification do
  @moduledoc """
  BoldSign Identity Verification API.
  """

  @doc """
  Creates an embedded verification URL.
  """
  def create_embedded_verification_url(client, params) do
    Req.post!(client, url: "/identityVerification/createEmbeddedVerificationUrl", json: params).body
  end

  @doc """
  Gets an identity verification report.
  """
  def get_report(client, verification_id) do
    Req.get!(client, url: "/identityVerification/report", params: [verificationId: verification_id]).body
  end

  @doc """
  Gets an identity verification image.
  """
  def get_image(client, verification_id, image_id) do
    Req.get!(client, url: "/identityVerification/image", params: [verificationId: verification_id, imageId: image_id]).body
  end
end
