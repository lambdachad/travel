defmodule Travel.Stays.Accommodation do
  @moduledoc """
  Get, list, suggest, and review accommodations.

  ## Endpoints

    * `GET /stays/accommodation/{id}` - Get accommodation
    * `GET /stays/accommodation` - List accommodations
    * `POST /stays/accommodation/suggestions` - Get suggestions
    * `GET /stays/accommodation/{id}/reviews` - Get reviews

  ## Examples

      # Get accommodation by ID
      {:ok, response} = Travel.Stays.Accommodation.get("acc_123")

      # List accommodations near a location
      {:ok, response} = Travel.Stays.Accommodation.list(%{
        latitude: 51.5,
        longitude: -0.1,
        radius: 5
      })

      # Get suggestions for a query
      {:ok, response} = Travel.Stays.Accommodation.suggestions("Hilton London")

      # Get reviews for an accommodation
      {:ok, response} = Travel.Stays.Accommodation.reviews("acc_123")

  @link https://duffel.com/docs/api/stays/accommodation
  """

  alias Travel.Client
  alias Travel.Stays.Types

  @doc """
  Get an accommodation by ID.

  ## Parameters

    * `accommodation_id` - The accommodation ID

  ## Returns

    * `{:ok, %Travel.Types.DuffelResponse{data: %Types.StaysAccommodation{}}}` on success
    * `{:error, %Travel.Error{}}` on failure

  """
  @spec get(String.t()) ::
          {:ok, Travel.Types.DuffelResponse.t()} | {:error, Travel.Error.t() | term()}
  def get(accommodation_id) do
    config = Travel.config!()

    case Client.request(config, :get, "stays/accommodation/#{accommodation_id}") do
      {:ok, response} ->
        parsed_data = Types.parse_accommodation(response.data)
        {:ok, %{response | data: parsed_data}}

      {:error, error} ->
        {:error, error}
    end
  end

  @doc """
  List accommodations with optional location filtering and pagination.

  ## Parameters

    * `opts` - Optional query parameters:
      * `:latitude` - (required) Latitude for radius search
      * `:longitude` - (required) Longitude for radius search
      * `:radius` - (optional) Search radius in km
      * `:limit` - (optional) Results per page (max 200)
      * `:before` - (optional) Cursor for previous page
      * `:after` - (optional) Cursor for next page

  ## Returns

    * `{:ok, %Travel.Types.DuffelResponse{data: [%Types.StaysAccommodation{}]}}` on success
    * `{:error, %Travel.Error{}}` on failure

  """
  @spec list(map() | nil) ::
          {:ok, Travel.Types.DuffelResponse.t()} | {:error, Travel.Error.t() | term()}
  def list(opts \\ nil) do
    config = Travel.config!()

    case Client.request(config, :get, "stays/accommodation", nil, opts) do
      {:ok, response} ->
        parsed_data = Enum.map(response.data, &Types.parse_accommodation/1)
        {:ok, %{response | data: parsed_data}}

      {:error, error} ->
        {:error, error}
    end
  end

  @doc """
  List all accommodations as a stream, handling pagination automatically.

  ## Parameters

    * `opts` - Query parameters including `latitude`, `longitude`, `radius`

  ## Returns

    A `Stream` that yields `%Travel.Types.DuffelResponse{}` for each page.

  """
  @spec stream(map()) :: Enumerable.t()
  def stream(opts) do
    config = Travel.config!()

    Client.stream(config, "stays/accommodation", opts)
    |> Stream.map(fn response ->
      parsed_data = Enum.map(response.data, &Types.parse_accommodation/1)
      %{response | data: parsed_data}
    end)
  end

  @doc """
  Get accommodation suggestions for a query string.

  ## Parameters

    * `query` - Search query string
    * `location` - (optional) Location filter with `radius` and `geographic_coordinates`

  ## Returns

    * `{:ok, %Travel.Types.DuffelResponse{data: [%Types.StaysAccommodationSuggestion{}]}}` on success
    * `{:error, %Travel.Error{}}` on failure

  """
  @spec suggestions(String.t(), map() | nil) ::
          {:ok, Travel.Types.DuffelResponse.t()} | {:error, Travel.Error.t() | term()}
  def suggestions(query, location \\ nil) do
    config = Travel.config!()
    body = %{query: query}
    body = if location, do: Map.put(body, :location, location), else: body

    case Client.request(config, :post, "stays/accommodation/suggestions", body) do
      {:ok, response} ->
        parsed_data = Enum.map(response.data, &Types.parse_accommodation_suggestion/1)
        {:ok, %{response | data: parsed_data}}

      {:error, error} ->
        {:error, error}
    end
  end

  @doc """
  Get reviews for an accommodation.

  ## Parameters

    * `accommodation_id` - The accommodation ID
    * `opts` - (optional) Pagination options (`limit`, `before`, `after`)

  ## Returns

    * `{:ok, %Travel.Types.DuffelResponse{data: %Types.StaysAccommodationReviewResponse{}}}` on success
    * `{:error, %Travel.Error{}}` on failure

  """
  @spec reviews(String.t(), map() | nil) ::
          {:ok, Travel.Types.DuffelResponse.t()} | {:error, Travel.Error.t() | term()}
  def reviews(accommodation_id, opts \\ nil) do
    config = Travel.config!()

    case Client.request(
           config,
           :get,
           "stays/accommodation/#{accommodation_id}/reviews",
           nil,
           opts
         ) do
      {:ok, response} ->
        parsed_data = Types.parse_review_response(response.data)
        {:ok, %{response | data: parsed_data}}

      {:error, error} ->
        {:error, error}
    end
  end
end
