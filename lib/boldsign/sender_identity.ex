defmodule Boldsign.SenderIdentity do
  @moduledoc """
  BoldSign Sender Identity API.
  """

  @doc """
  Lists sender identities.
  """
  def list(client, params \\ []) do
    Req.get!(client, url: "/senderIdentities/list", params: params).body
  end

  @doc """
  Gets a sender identity's properties.
  """
  def get_properties(client, email) do
    Req.get!(client, url: "/senderIdentities/properties", params: [email: email]).body
  end

  @doc """
  Creates a new sender identity.
  """
  def create(client, params) do
    Req.post!(client, url: "/senderIdentities/create", json: params).body
  end

  @doc """
  Updates a sender identity.
  """
  def update(client, params) do
    Req.post!(client, url: "/senderIdentities/update", json: params).body
  end

  @doc """
  Deletes a sender identity.
  """
  def delete(client, email) do
    Req.delete!(client, url: "/senderIdentities/delete", params: [email: email]).body
  end

  @doc """
  Resends an invitation to a sender identity.
  """
  def resend_invitation(client, email) do
    Req.post!(client, url: "/senderIdentities/resendInvitation", params: [email: email]).body
  end

  @doc """
  Rerequests a sender identity.
  """
  def rerequest(client, email) do
    Req.post!(client, url: "/senderIdentities/rerequest", params: [email: email]).body
  end
end
