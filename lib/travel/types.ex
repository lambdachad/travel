defmodule Travel.Types do
  @moduledoc """
  Shared types used across the Travel API client.
  """

  use TypedStruct

  typedstruct module: PaginationMeta do
    @typedoc """
    Pagination metadata returned from list endpoints.

    ## Fields

      * `:limit` - The number of results per page
      * `:before` - Cursor for the previous page
      * `:after` - Cursor for the next page
    """

    field(:limit, integer() | nil)
    field(:before, String.t() | nil)
    field(:after, String.t() | nil)
  end

  typedstruct module: DuffelResponse, typeparam: [:data] do
    @typedoc """
    Standard response wrapper from the Duffel API.

    ## Fields

      * `:data` - The response data (type varies by endpoint)
      * `:meta` - Pagination metadata (present on list endpoints)
      * `:headers` - Raw HTTP response headers
      * `:status` - HTTP status code
    """

    field(:data, any())
    field(:meta, PaginationMeta.t() | nil)
    field(:headers, map(), default: %{})
    field(:status, integer(), default: 200)
  end

  @doc """
  Parses a raw HTTP response into a `DuffelResponse` struct.

  Handles both single-item and paginated responses.
  """
  @spec parse_response(map(), integer(), map()) :: DuffelResponse.t()
  def parse_response(body, status, headers) do
    %DuffelResponse{
      data: body["data"],
      meta: parse_meta(body["meta"]),
      headers: headers,
      status: status
    }
  end

  defp parse_meta(nil), do: nil

  defp parse_meta(meta) do
    %PaginationMeta{
      limit: meta["limit"],
      before: meta["before"],
      after: meta["after"]
    }
  end
end
