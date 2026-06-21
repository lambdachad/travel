defmodule Travel.Flights.OfferRequests do
  @moduledoc """
  Create and retrieve offer requests for flight searches.

  ## Endpoints

    * `POST /air/offer_requests` - Create an offer request
    * `GET /air/offer_requests/{id}` - Get an offer request
    * `GET /air/offer_requests` - List offer requests

  ## Examples

      # Create an offer request
      {:ok, response} = Travel.Flights.OfferRequests.create(%{
        slices: [
          %{origin: "LHR", destination: "JFK", departure_date: "2025-06-01"}
        ],
        passengers: [%{type: "adult"}]
      })

      # Create and return offers in the response
      {:ok, response} = Travel.Flights.OfferRequests.create(%{
        slices: [...],
        passengers: [...]
      }, %{return_offers: true})

      # Get an offer request
      {:ok, response} = Travel.Flights.OfferRequests.get("orq_123")

  @link https://duffel.com/docs/api/offer-requests
  """

  alias Travel.Client
  alias Travel.Flights.Types

  @doc """
  Create an offer request.

  ## Parameters

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
  @spec create(map(), map() | nil) ::
          {:ok, Travel.Types.DuffelResponse.t()} | {:error, Travel.Error.t() | term()}
  def create(params, opts \\ nil) do
    config = Travel.config!()

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

    * `offer_request_id` - The offer request ID

  ## Returns

    * `{:ok, %Travel.Types.DuffelResponse{data: %Types.OfferRequest{}}}` on success
    * `{:error, %Travel.Error{}}` on failure

  """
  @spec get(String.t()) ::
          {:ok, Travel.Types.DuffelResponse.t()} | {:error, Travel.Error.t() | term()}
  def get(offer_request_id) do
    config = Travel.config!()

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

    * `opts` - Optional pagination parameters (`limit`, `before`, `after`)

  ## Returns

    * `{:ok, %Travel.Types.DuffelResponse{data: [%Types.OfferRequest{}]}}` on success
    * `{:error, %Travel.Error{}}` on failure

  """
  @spec list(map() | nil) ::
          {:ok, Travel.Types.DuffelResponse.t()} | {:error, Travel.Error.t() | term()}
  def list(opts \\ nil) do
    config = Travel.config!()

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
  @spec stream() :: Enumerable.t()
  def stream do
    config = Travel.config!()

    Client.stream(config, "air/offer_requests")
    |> Stream.map(fn response ->
      parsed_data = Enum.map(response.data, &Types.parse_offer_request/1)
      %{response | data: parsed_data}
    end)
  end
end
