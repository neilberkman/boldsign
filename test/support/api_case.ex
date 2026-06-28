defmodule Boldsign.ApiCase do
  @moduledoc false
  use ExUnit.CaseTemplate

  using opts do
    quote do
      use ExUnit.Case, unquote(opts)

      import Boldsign.ApiCase
      import Plug.Conn
    end
  end

  setup do
    bypass = Bypass.open()
    client = Boldsign.new(api_key: "test_key", base_url: "http://localhost:#{bypass.port}/v1")

    {:ok, bypass: bypass, client: client}
  end

  def json_response(conn, status, body) do
    conn
    |> Plug.Conn.put_resp_content_type("application/json")
    |> Plug.Conn.send_resp(status, Jason.encode!(body))
  end

  def read_json_body(conn) do
    {:ok, body, conn} = Plug.Conn.read_body(conn)
    {Jason.decode!(body), conn}
  end

  def fetch_query(conn), do: Plug.Conn.fetch_query_params(conn)
end
