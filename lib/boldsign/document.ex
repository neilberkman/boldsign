defmodule Boldsign.Document do
  @moduledoc """
  BoldSign Document API.
  """

  @doc """
  Sends a document for signature.

  Supports two modes:
  - **JSON** (default): params are sent as JSON, including `:fileUrls`.
  - **Multipart** (`:files`): when non-empty `Boldsign.File` tuples are passed,
    the request is sent as multipart form data with files + JSON-stringified
    param fields (matching BoldSign's official SDK conventions).
  """
  def send(client, params) do
    Boldsign.Request.request!(client, :post, "/document/send", body: params, multipart: true)
  end

  @doc """
  Creates a document draft.
  """
  def create(client, params) do
    Boldsign.Request.request!(client, :post, "/document/create", body: params, multipart: true)
  end

  @doc """
  Edits a document.
  """
  def edit(client, params) when is_map(params) or is_list(params) do
    {document_id, body} =
      Boldsign.Request.pop_required_query_param(params, "documentId", [:documentId, "documentId"])

    edit(client, document_id, body)
  end

  def edit(client, document_id, params) do
    Boldsign.Request.request!(
      client,
      :put,
      "/document/edit",
      query: [documentId: document_id],
      body: params,
      multipart: true
    )
  end

  @doc """
  Deletes a document.
  """
  def delete(client, document_id, params \\ []) do
    query = [documentId: document_id] ++ Boldsign.Request.query_list(params)
    Boldsign.Request.request!(client, :delete, "/document/delete", query: query)
  end

  @doc """
  Downloads a document.
  """
  def download(client, document_id, params \\ []) do
    query = [documentId: document_id] ++ Boldsign.Request.query_list(params)
    Boldsign.Request.request!(client, :get, "/document/download", query: query)
  end

  @doc """
  Downloads a document attachment.
  """
  def download_attachment(client, document_id, attachment_id, params \\ []) do
    query =
      [documentId: document_id, attachmentId: attachment_id] ++ Boldsign.Request.query_list(params)

    Boldsign.Request.request!(client, :get, "/document/downloadAttachment", query: query)
  end

  @doc """
  Downloads a document audit log.
  """
  def download_audit_log(client, document_id, params \\ []) do
    query = [documentId: document_id] ++ Boldsign.Request.query_list(params)
    Boldsign.Request.request!(client, :get, "/document/downloadAuditLog", query: query)
  end

  @doc """
  Gets the properties of a document.
  """
  def get_properties(client, document_id) do
    Boldsign.Request.request!(client, :get, "/document/properties", query: [documentId: document_id])
  end

  @doc """
  Lists documents.
  """
  def list(client, params \\ []) do
    Boldsign.Request.request!(client, :get, "/document/list", query: params)
  end

  @doc """
  Lists team documents.
  """
  def team_list(client, params \\ []) do
    Boldsign.Request.request!(client, :get, "/document/teamlist", query: params)
  end

  @doc """
  Lists documents sent on behalf of or by other senders.
  """
  def behalf_list(client, params \\ []) do
    Boldsign.Request.request!(client, :get, "/document/behalfList", query: params)
  end

  @doc """
  Reminds signers about a document.
  """
  def remind(client, document_id, params \\ %{}) do
    {query, body} =
      Boldsign.Request.split_query_params(params, [
        {"receiverEmails", [:receiverEmails, "receiverEmails"]}
      ])

    # BoldSign expects receiverEmails as repeated query params
    # (?receiverEmails=a&receiverEmails=b). Req raises on a list query value, so
    # expand a list into one query entry per email. Omit entirely to remind all
    # pending signers.
    query =
      Enum.flat_map([documentId: document_id] ++ query, fn
        {"receiverEmails", emails} when is_list(emails) ->
          Enum.map(emails, &{"receiverEmails", &1})

        pair ->
          [pair]
      end)

    Boldsign.Request.request!(client, :post, "/document/remind", query: query, body: body)
  end

  @doc """
  Revokes a document.
  """
  def revoke(client, document_id, params \\ %{}) do
    Boldsign.Request.request!(
      client,
      :post,
      "/document/revoke",
      query: [documentId: document_id],
      body: params
    )
  end

  @doc """
  Adds recipient authentication to a document.
  """
  def add_authentication(client, document_id, params) do
    Boldsign.Request.request!(
      client,
      :patch,
      "/document/addAuthentication",
      query: [documentId: document_id],
      body: params
    )
  end

  @doc """
  Removes recipient authentication from a document.
  """
  def remove_authentication(client, document_id, params) do
    Boldsign.Request.request!(
      client,
      :patch,
      "/document/RemoveAuthentication",
      query: [{"DocumentId", document_id}],
      body: params
    )
  end

  @doc """
  Adds tags to a document.
  """
  def add_tags(client, params) do
    Boldsign.Request.request!(client, :patch, "/document/addTags", body: params)
  end

  @doc """
  Deletes tags from a document.
  """
  def delete_tags(client, params) do
    Boldsign.Request.request!(client, :delete, "/document/deleteTags", body: params)
  end

  @doc """
  Changes a signer's access code.
  """
  def change_access_code(client, document_id, params) do
    {query, body} =
      Boldsign.Request.split_query_params(params, [
        {"EmailId", [:EmailId, :emailId, "EmailId", "emailId"]},
        {"ZOrder", [:ZOrder, :order, "ZOrder", "order"]}
      ])

    Boldsign.Request.request!(
      client,
      :patch,
      "/document/changeAccessCode",
      query: [{"DocumentId", document_id} | query],
      body: body
    )
  end

  @doc """
  Changes a document recipient.
  """
  def change_recipient(client, document_id, params) do
    Boldsign.Request.request!(
      client,
      :patch,
      "/document/changeRecipient",
      query: [documentId: document_id],
      body: params
    )
  end

  @doc """
  Extends a document's expiry.
  """
  def extend_expiry(client, document_id, params) do
    Boldsign.Request.request!(
      client,
      :patch,
      "/document/extendExpiry",
      query: [documentId: document_id],
      body: params
    )
  end

  @doc """
  Prefills document fields.
  """
  def prefill_fields(client, document_id, params) do
    Boldsign.Request.request!(
      client,
      :patch,
      "/document/prefillFields",
      query: [documentId: document_id],
      body: params
    )
  end

  @doc """
  Sends a draft document for signature.
  """
  def draft_send(client, document_id) do
    Boldsign.Request.request!(client, :post, "/document/draftSend", query: [documentId: document_id])
  end

  @doc """
  Cancels editing for a document.
  """
  def cancel_editing(client, document_id, params \\ []) do
    query = [documentId: document_id] ++ Boldsign.Request.query_list(params)
    Boldsign.Request.request!(client, :post, "/document/cancelEditing", query: query)
  end

  @doc """
  Creates an embedded signing link.
  """
  def get_embedded_sign_link(client, document_id, params \\ []) do
    query = [documentId: document_id] ++ Boldsign.Request.query_list(params)
    Boldsign.Request.request!(client, :get, "/document/getEmbeddedSignLink", query: query)
  end

  @doc """
  Creates an embedded edit URL for a document.
  """
  def create_embedded_edit_url(client, document_id, params \\ %{}) do
    Boldsign.Request.request!(
      client,
      :post,
      "/document/createEmbeddedEditUrl",
      query: [documentId: document_id],
      body: params,
      multipart: true
    )
  end

  @doc """
  Creates an embedded request URL.
  """
  def create_embedded_request_url(client, params) do
    Boldsign.Request.request!(
      client,
      :post,
      "/document/createEmbeddedRequestUrl",
      body: params,
      multipart: true
    )
  end
end
