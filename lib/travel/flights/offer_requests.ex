defmodule Travel.Flights.OfferRequests do
  @moduledoc """
  Create and retrieve offer requests for flight searches.

  ## Endpoints

    * `POST /air/offer_requests` - Create an offer request
    * `GET /air/offer_requests/{id}` - Get an offer request
    * `GET /air/offer_requests` - List offer requests

  ## Examples

      config = Travel.new(access_token: "duffel_test_xxx")

      # Create an offer request
      {:ok, response} = Travel.Flights.OfferRequests.create(config, %{
        slices: [
          %{origin: "LHR", destination: "JFK", departure_date: "2025-06-01"}
        ],
        passengers: [%{type: "adult"}]
      })

      # Create and return offers in the response
      {:ok, response} = Travel.Flights.OfferRequests.create(config, %{
        slices: [...],
        passengers: [...]
      }, %{return_offers: true})

      # Get an offer request
      {:ok, response} = Travel.Flights.OfferRequests.get(config, "orq_123")

  @link https://duffel.com/docs/api/offer-requests
  """

  alias Travel.Client
  alias Travel.Flights.Types

  @doc """
  Create an offer request.

  ## Parameters

    * `config` - Travel configuration
    * `params` - Offer request parameters:
      * `:slices` - (required) List of trip segments
      * `:passengers` - (required) List of passengers
      * `:cabin_class` - (optional) Preferred cabin class
      * `:max_connections` - (optional) Maximum connections per slice
      * `:private_fares` - (optional) Private fare codes
      * `:airline_credit_ids` - (optional) Airline credit IDs to use
    * `opts` - Optional query parameters:
      * `:return_offers` - Include offers in response
      * `:supplier_timeout` - Supplier timeout in ms

  ## Returns

    * `{:ok, %Travel.Types.DuffelResponse{data: %Types.OfferRequest{}}}` on success
    * `{:error, %Travel.Error{}}` on failure

  """
  @spec create(Travel.t(), map(), map() | nil) ::
          {:ok, Travel.Types.DuffelResponse.t()} | {:error, Travel.Error.t() | term()}
  def create(config, params, opts \\ nil) do
    query_params =
      if opts do
        opts
        |> Map.take([:return_offers, :supplier_timeout])
        |> Enum.reject(fn {_, v} -> is_nil(v) end)
        |> Map.new()
      else
        %{}
      end

    body = Map.drop(params, [:return_offers, :supplier_timeout])

    case Client.request(config, :post, "air/offer_requests", body, query_params) do
      {:ok, response} ->
        parsed_data = Types.parse_offer_request(response.data)
        {:ok, %{response | data: parsed_data}}

      {:error, error} ->
        {:error, error}
    end
  end

  @doc """
  Get an offer request by ID.

  ## Parameters

    * `config` - Travel configuration
    * `offer_request_id` - The offer request ID

  ## Returns

    * `{:ok, %Travel.Types.DuffelResponse{data: %Types.OfferRequest{}}}` on success
    * `{:error, %Travel.Error{}}` on failure

  """
  @spec get(Travel.t(), String.t()) ::
          {:ok, Travel.Types.DuffelResponse.t()} | {:error, Travel.Error.t() | term()}
  def get(config, offer_request_id) do
    case Client.request(config, :get, "air/offer_requests/#{offer_request_id}") do
      {:ok, response} ->
        parsed_data = Types.parse_offer_request(response.data)
        {:ok, %{response | data: parsed_data}}

      {:error, error} ->
        {:error, error}
    end
  end

  @doc """
  List offer requests with pagination.

  ## Parameters

    * `config` - Travel configuration
    * `opts` - Optional pagination parameters (`limit`, `before`, `after`)

  ## Returns

    * `{:ok, %Travel.Types.DuffelResponse{data: [%Types.OfferRequest{}]}}` on success
    * `{:error, %Travel.Error{}}` on failure

  """
  @spec list(Travel.t(), map() | nil) ::
          {:ok, Travel.Types.DuffelResponse.t()} | {:error, Travel.Error.t() | term()}
  def list(config, opts \\ nil) do
    case Client.request(config, :get, "air/offer_requests", nil, opts) do
      {:ok, response} ->
        parsed_data = Enum.map(response.data, &Types.parse_offer_request/1)
        {:ok, %{response | data: parsed_data}}

      {:error, error} ->
        {:error, error}
    end
  end

  @doc """
  Stream all offer requests with automatic pagination.

  ## Returns

    A `Stream` that yields `%Travel.Types.DuffelResponse{}` for each page.

  """
  @spec stream(Travel.t()) :: Enumerable.t()
  def stream(config) do
    Client.stream(config, "air/offer_requests")
    |> Stream.map(fn response ->
      parsed_data = Enum.map(response.data, &Types.parse_offer_request/1)
      %{response | data: parsed_data}
    end)
  end
end
