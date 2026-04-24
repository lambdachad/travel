defmodule Travel.Stays.Accommodation do
  @moduledoc """
  Get, list, suggest, and review accommodations.

  ## Endpoints

    * `GET /stays/accommodation/{id}` - Get accommodation
    * `GET /stays/accommodation` - List accommodations
    * `POST /stays/accommodation/suggestions` - Get suggestions
    * `GET /stays/accommodation/{id}/reviews` - Get reviews

  ## Examples

      config = Travel.new(access_token: "duffel_test_xxx")

      # Get accommodation by ID
      {:ok, response} = Travel.Stays.Accommodation.get(config, "acc_123")

      # List accommodations near a location
      {:ok, response} = Travel.Stays.Accommodation.list(config, %{
        latitude: 51.5,
        longitude: -0.1,
        radius: 5
      })

      # Get suggestions for a query
      {:ok, response} = Travel.Stays.Accommodation.suggestions(config, "Hilton London")

      # Get reviews for an accommodation
      {:ok, response} = Travel.Stays.Accommodation.reviews(config, "acc_123")

  @link https://duffel.com/docs/api/stays/accommodation
  """

  alias Travel.Client
  alias Travel.Stays.Types

  @doc """
  Get an accommodation by ID.

  ## Parameters

    * `config` - Travel configuration
    * `accommodation_id` - The accommodation ID

  ## Returns

    * `{:ok, %Travel.Types.DuffelResponse{data: %Types.StaysAccommodation{}}}` on success
    * `{:error, %Travel.Error{}}` on failure

  """
  @spec get(Travel.t(), String.t()) ::
          {:ok, Travel.Types.DuffelResponse.t()} | {:error, Travel.Error.t() | term()}
  def get(config, accommodation_id) do
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

    * `config` - Travel configuration
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
  @spec list(Travel.t(), map() | nil) ::
          {:ok, Travel.Types.DuffelResponse.t()} | {:error, Travel.Error.t() | term()}
  def list(config, opts \\ nil) do
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

    * `config` - Travel configuration
    * `opts` - Query parameters including `latitude`, `longitude`, `radius`

  ## Returns

    A `Stream` that yields `%Travel.Types.DuffelResponse{}` for each page.

  """
  @spec stream(Travel.t(), map()) :: Enumerable.t()
  def stream(config, opts) do
    Client.stream(config, "stays/accommodation", opts)
    |> Stream.map(fn response ->
      parsed_data = Enum.map(response.data, &Types.parse_accommodation/1)
      %{response | data: parsed_data}
    end)
  end

  @doc """
  Get accommodation suggestions for a query string.

  ## Parameters

    * `config` - Travel configuration
    * `query` - Search query string
    * `location` - (optional) Location filter with `radius` and `geographic_coordinates`

  ## Returns

    * `{:ok, %Travel.Types.DuffelResponse{data: [%Types.StaysAccommodationSuggestion{}]}}` on success
    * `{:error, %Travel.Error{}}` on failure

  """
  @spec suggestions(Travel.t(), String.t(), map() | nil) ::
          {:ok, Travel.Types.DuffelResponse.t()} | {:error, Travel.Error.t() | term()}
  def suggestions(config, query, location \\ nil) do
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

    * `config` - Travel configuration
    * `accommodation_id` - The accommodation ID
    * `opts` - (optional) Pagination options (`limit`, `before`, `after`)

  ## Returns

    * `{:ok, %Travel.Types.DuffelResponse{data: %Types.StaysAccommodationReviewResponse{}}}` on success
    * `{:error, %Travel.Error{}}` on failure

  """
  @spec reviews(Travel.t(), String.t(), map() | nil) ::
          {:ok, Travel.Types.DuffelResponse.t()} | {:error, Travel.Error.t() | term()}
  def reviews(config, accommodation_id, opts \\ nil) do
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
