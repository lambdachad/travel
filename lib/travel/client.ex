defmodule Travel.Client do
  @moduledoc """
  HTTP client for the Duffel API built on Req.

  Handles authentication, request formatting, response parsing, and error handling.

  ## Request Format

  All POST/PATCH requests wrap the payload in a `data` key as required by the Duffel API:

      # You pass: %{check_in_date: "2025-06-01"}
      # API receives: %{data: %{check_in_date: "2025-06-01"}}

  ## Response Format

  Responses are parsed into `{:ok, Travel.Types.DuffelResponse}` tuples.
  Errors are returned as `{:error, Travel.Error}` tuples.
  """

  alias Travel.Types, as: T

  @doc """
  Makes an HTTP request to the Duffel API.

  ## Parameters

    * `config` - A `Travel` configuration struct
    * `method` - HTTP method (`:get`, `:post`, `:patch`, `:delete`)
    * `path` - API path (e.g., `"stays/search"`)
    * `body` - (optional) Request body, will be wrapped in `data` key
    * `query_params` - (optional) Query string parameters

  ## Returns

    * `{:ok, %T.DuffelResponse{}}` on success
    * `{:error, %Travel.Error{}}` on API error
    * `{:error, reason}` on network/HTTP error

  ## Examples

      config = Travel.new(access_token: "duffel_test_xxx")

      Travel.Client.request(config, :post, "stays/search", %{
        location: %{...},
        check_in_date: "2025-06-01",
        check_out_date: "2025-06-05",
        rooms: 1,
        guests: [%{type: "adult"}]
      })

  """
  @spec request(
          Travel.t(),
          atom(),
          String.t(),
          map() | nil,
          map() | nil
        ) ::
          {:ok, T.DuffelResponse.t()} | {:error, Travel.Error.t() | term()}
  def request(config, method, path, body \\ nil, query_params \\ nil) do
    url = build_url(config, path, query_params)

    req =
      Req.new(
        url: url,
        method: method,
        headers: build_headers(config),
        json: build_body(body),
        retry: :transient,
        max_retries: 2,
        receive_timeout: 130_000
      )

    case Req.request(req) do
      {:ok, response} ->
        case response.status do
          status when status in 200..299 ->
            parsed = T.parse_response(response.body, status, response.headers)
            {:ok, parsed}

          status ->
            error = Travel.Error.from_response(response.body, status)
            {:error, error}
        end

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Makes a paginated request that returns a stream of all pages.

  Uses cursor-based pagination. Each page is yielded as it's fetched.

  ## Examples

      config = Travel.new(access_token: "duffel_test_xxx")

      Travel.Client.stream(config, "stays/bookings")
      |> Enum.each(fn response ->
        IO.inspect(response.data)
      end)

  """
  @spec stream(Travel.t(), String.t(), map() | nil) :: Enumerable.t()
  def stream(config, path, query_params \\ nil) do
    Stream.unfold({config, path, query_params, nil}, fn
      {config, path, query_params, nil} ->
        case request(config, :get, path, nil, query_params) do
          {:ok, %T.DuffelResponse{meta: %{after: cursor}} = resp} when not is_nil(cursor) ->
            {resp, {config, path, query_params, cursor}}

          {:ok, resp} ->
            {resp, nil}

          {:error, error} ->
            raise "Stream request failed: #{error}"
        end

      {config, path, base_params, cursor} ->
        params = Map.merge(base_params || %{}, %{"after" => cursor})

        case request(config, :get, path, nil, params) do
          {:ok, %T.DuffelResponse{meta: %{after: next_cursor}} = resp}
          when not is_nil(next_cursor) ->
            {resp, {config, path, base_params, next_cursor}}

          {:ok, resp} ->
            {resp, nil}

          {:error, error} ->
            raise "Stream request failed: #{error}"
        end

      nil ->
        nil
    end)
  end

  defp build_url(config, path, query_params) do
    uri = URI.parse("#{config.base_url}/#{path}")

    if query_params && map_size(query_params) > 0 do
      query =
        query_params
        |> Enum.reject(fn {_, v} -> is_nil(v) end)
        |> URI.encode_query()

      %{uri | query: query} |> URI.to_string()
    else
      URI.to_string(uri)
    end
  end

  defp build_headers(config) do
    user_agent = "Travel/elixir #{Application.spec(:travel, :vsn) || "0.1.0"}"

    %{
      "Accept" => "application/json",
      "Content-Type" => "application/json",
      "Authorization" => "Bearer #{config.access_token}",
      "Duffel-Version" => config.api_version,
      "User-Agent" => user_agent
    }
  end

  defp build_body(nil), do: nil

  defp build_body(body) do
    %{"data" => body}
  end
end
