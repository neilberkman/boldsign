defmodule Boldsign.Team do
  @moduledoc """
  BoldSign Team API.
  """

  @doc """
  Lists teams.
  """
  def list(client, params \\ []) do
    Boldsign.Request.request!(client, :get, "/teams/list", query: params)
  end

  @doc """
  Gets a team's details.
  """
  def get(client, team_id) do
    Boldsign.Request.request!(client, :get, "/teams/get", query: [teamId: team_id])
  end

  @doc """
  Creates a new team.
  """
  def create(client, params) do
    Boldsign.Request.request!(client, :post, "/teams/create", body: params)
  end

  @doc """
  Updates a team's details.
  """
  def update(client, params) do
    Boldsign.Request.request!(client, :put, "/teams/update", body: params)
  end
end
