defmodule Travel.Flights.Offers do
  @moduledoc """
  Get, list, update, and price flight offers.

  ## Endpoints

    * `GET /air/offers/{id}` - Get an offer
    * `GET /air/offers` - List offers for an offer request
    * `PATCH /air/offers/{id}/passengers/{passenger_id}` - Update offer passenger
    * `POST /air/offers/{id}/actions/price` - Price an offer

  ## Examples

      config = Travel.new(access_token: "duffel_test_xxx")

      # List offers for an offer request
      {:ok, response} = Travel.Flights.Offers.list(config, "orq_123")

      # Get a specific offer
      {:ok, response} = Travel.Flights.Offers.get(config, "off_123")

      # Price an offer
      {:ok, response} = Travel.Flights.Offers.get_priced(config, "off_123", %{
        intended_payment_methods: [%{type: "balance"}],
        intended_services: []
      })

  @link https://duffel.com/docs/api/offers
  """

  alias Travel.Client
  alias Travel.Flights.Types

  @doc """
  Get an offer by ID.

  ## Parameters

    * `config` - Travel configuration
    * `offer_id` - The offer ID
    * `opts` - Optional query parameters (`return_available_services`)

  ## Returns

    * `{:ok, %Travel.Types.DuffelResponse{data: %Types.Offer{}}}` on success
    * `{:error, %Travel.Error{}}` on failure

  """
  @spec get(Travel.t(), String.t(), map() | nil) ::
          {:ok, Travel.Types.DuffelResponse.t()} | {:error, Travel.Error.t() | term()}
  def get(config, offer_id, opts \\ nil) do
    case Client.request(config, :get, "air/offers/#{offer_id}", nil, opts) do
      {:ok, response} ->
        parsed_data = Types.parse_offer(response.data)
        {:ok, %{response | data: parsed_data}}

      {:error, error} ->
        {:error, error}
    end
  end

  @doc """
  List offers for an offer request.

  ## Parameters

    * `config` - Travel configuration
    * `offer_request_id` - The offer request ID
    * `opts` - Optional parameters (`limit`, `before`, `after`, `max_connections`, `sort`)

  ## Returns

    * `{:ok, %Travel.Types.DuffelResponse{data: [%Types.Offer{}]}}` on success
    * `{:error, %Travel.Error{}}` on failure

  """
  @spec list(Travel.t(), String.t(), map() | nil) ::
          {:ok, Travel.Types.DuffelResponse.t()} | {:error, Travel.Error.t() | term()}
  def list(config, offer_request_id, opts \\ nil) do
    query_params = Map.merge(opts || %{}, %{"offer_request_id" => offer_request_id})

    case Client.request(config, :get, "air/offers", nil, query_params) do
      {:ok, response} ->
        parsed_data = Enum.map(response.data, &Types.parse_offer/1)
        {:ok, %{response | data: parsed_data}}

      {:error, error} ->
        {:error, error}
    end
  end

  @doc """
  Stream all offers with automatic pagination.

  ## Returns

    A `Stream` that yields `%Travel.Types.DuffelResponse{}` for each page.

  """
  @spec stream(Travel.t(), String.t(), map() | nil) :: Enumerable.t()
  def stream(config, offer_request_id, opts \\ nil) do
    query_params = Map.merge(opts || %{}, %{"offer_request_id" => offer_request_id})

    Client.stream(config, "air/offers", query_params)
    |> Stream.map(fn response ->
      parsed_data = Enum.map(response.data, &Types.parse_offer/1)
      %{response | data: parsed_data}
    end)
  end

  @doc """
  Update passenger details on an offer.

  ## Parameters

    * `config` - Travel configuration
    * `offer_id` - The offer ID
    * `passenger_id` - The passenger ID
    * `params` - Update parameters (`given_name`, `family_name`, `loyalty_programme_accounts`)

  ## Returns

    * `{:ok, %Travel.Types.DuffelResponse{data: %Types.Offer{}}}` on success
    * `{:error, %Travel.Error{}}` on failure

  """
  @spec update(Travel.t(), String.t(), String.t(), map()) ::
          {:ok, Travel.Types.DuffelResponse.t()} | {:error, Travel.Error.t() | term()}
  def update(config, offer_id, passenger_id, params) do
    path = "air/offers/#{offer_id}/passengers/#{passenger_id}"

    case Client.request(config, :patch, path, params) do
      {:ok, response} ->
        parsed_data = Types.parse_offer(response.data)
        {:ok, %{response | data: parsed_data}}

      {:error, error} ->
        {:error, error}
    end
  end

  @doc """
  Price an offer with intended payment methods and services.

  ## Parameters

    * `config` - Travel configuration
    * `offer_id` - The offer ID
    * `params` - Pricing parameters:
      * `:intended_payment_methods` - List of payment method objects
      * `:intended_services` - List of service objects

  ## Returns

    * `{:ok, %Travel.Types.DuffelResponse{data: %Types.OfferPriced{}}}` on success
    * `{:error, %Travel.Error{}}` on failure

  """
  @spec get_priced(Travel.t(), String.t(), map()) ::
          {:ok, Travel.Types.DuffelResponse.t()} | {:error, Travel.Error.t() | term()}
  def get_priced(config, offer_id, params) do
    path = "air/offers/#{offer_id}/actions/price"

    case Client.request(config, :post, path, params) do
      {:ok, response} ->
        parsed_data = Types.parse_offer_priced(response.data)
        {:ok, %{response | data: parsed_data}}

      {:error, error} ->
        {:error, error}
    end
  end
end
