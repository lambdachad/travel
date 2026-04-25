defmodule Travel.Flights.Orders do
  @moduledoc """
  Create, retrieve, list, and manage flight orders.

  ## Endpoints

    * `POST /air/orders` - Create an order
    * `GET /air/orders/{id}` - Get an order
    * `GET /air/orders` - List orders
    * `PATCH /air/orders/{id}` - Update an order
    * `GET /air/orders/{id}/available_services` - Get available services
    * `POST /air/orders/{id}/services` - Add services to an order

  ## Examples

      config = Travel.new(access_token: "duffel_test_xxx")

      # Create an order
      {:ok, response} = Travel.Flights.Orders.create(config, %{
        selected_offers: [%{offer_id: "off_123", passenger_ids: ["pas_123"]}],
        passengers: [%{
          given_name: "John",
          family_name: "Smith",
          born_on: "1990-01-01",
          gender: "m",
          title: "mr",
          email: "john@example.com",
          phone_number: "+447700900000"
        }],
        type: "instant"
      })

      # Get an order
      {:ok, response} = Travel.Flights.Orders.get(config, "ord_123")

      # Update order metadata
      {:ok, response} = Travel.Flights.Orders.update(config, "ord_123", %{
        metadata: %{"payment_intent_id" => "pit_123"}
      })

  @link https://duffel.com/docs/api/orders
  """

  alias Travel.Client
  alias Travel.Flights.Types

  @doc """
  Create an order from an offer.

  ## Parameters

    * `config` - Travel configuration
    * `params` - Order parameters:
      * `:selected_offers` - (required) List of selected offers with passenger IDs
      * `:passengers` - (required) List of passenger details
      * `:type` - (required) `"instant"` or `"pay_later"`
      * `:services` - (optional) Additional services to add
      * `:payments` - (optional) Payment details for pay-later orders
      * `:metadata` - (optional) Custom metadata
      * `:users` - (optional) User IDs for order management

  ## Returns

    * `{:ok, %Travel.Types.DuffelResponse{data: %Types.Order{}}}` on success
    * `{:error, %Travel.Error{}}` on failure

  """
  @spec create(Travel.t(), map()) ::
          {:ok, Travel.Types.DuffelResponse.t()} | {:error, Travel.Error.t() | term()}
  def create(config, params) do
    case Client.request(config, :post, "air/orders", params) do
      {:ok, response} ->
        parsed_data = Types.parse_order(response.data)
        {:ok, %{response | data: parsed_data}}

      {:error, error} ->
        {:error, error}
    end
  end

  @doc """
  Get an order by ID.

  ## Parameters

    * `config` - Travel configuration
    * `order_id` - The order ID

  ## Returns

    * `{:ok, %Travel.Types.DuffelResponse{data: %Types.Order{}}}` on success
    * `{:error, %Travel.Error{}}` on failure

  """
  @spec get(Travel.t(), String.t()) ::
          {:ok, Travel.Types.DuffelResponse.t()} | {:error, Travel.Error.t() | term()}
  def get(config, order_id) do
    case Client.request(config, :get, "air/orders/#{order_id}") do
      {:ok, response} ->
        parsed_data = Types.parse_order(response.data)
        {:ok, %{response | data: parsed_data}}

      {:error, error} ->
        {:error, error}
    end
  end

  @doc """
  List orders with optional filtering and pagination.

  ## Parameters

    * `config` - Travel configuration
    * `opts` - Optional parameters:
      * `:limit` - Results per page
      * `:before` / `:after` - Pagination cursors
      * `:awaiting_payment` - Filter by payment state
      * `:booking_reference` - Filter by booking reference
      * `:passenger_name` - Filter by passenger name
      * `:user_id` - Filter by user ID

  ## Returns

    * `{:ok, %Travel.Types.DuffelResponse{data: [%Types.Order{}]}}` on success
    * `{:error, %Travel.Error{}}` on failure

  """
  @spec list(Travel.t(), map() | nil) ::
          {:ok, Travel.Types.DuffelResponse.t()} | {:error, Travel.Error.t() | term()}
  def list(config, opts \\ nil) do
    case Client.request(config, :get, "air/orders", nil, opts) do
      {:ok, response} ->
        parsed_data = Enum.map(response.data, &Types.parse_order/1)
        {:ok, %{response | data: parsed_data}}

      {:error, error} ->
        {:error, error}
    end
  end

  @doc """
  Stream all orders with automatic pagination.

  ## Returns

    A `Stream` that yields `%Travel.Types.DuffelResponse{}` for each page.

  """
  @spec stream(Travel.t(), map() | nil) :: Enumerable.t()
  def stream(config, opts \\ nil) do
    Client.stream(config, "air/orders", opts)
    |> Stream.map(fn response ->
      parsed_data = Enum.map(response.data, &Types.parse_order/1)
      %{response | data: parsed_data}
    end)
  end

  @doc """
  Update an order's metadata.

  ## Parameters

    * `config` - Travel configuration
    * `order_id` - The order ID
    * `params` - Update parameters (typically `metadata`)

  ## Returns

    * `{:ok, %Travel.Types.DuffelResponse{data: %Types.Order{}}}` on success
    * `{:error, %Travel.Error{}}` on failure

  """
  @spec update(Travel.t(), String.t(), map()) ::
          {:ok, Travel.Types.DuffelResponse.t()} | {:error, Travel.Error.t() | term()}
  def update(config, order_id, params) do
    case Client.request(config, :patch, "air/orders/#{order_id}", params) do
      {:ok, response} ->
        parsed_data = Types.parse_order(response.data)
        {:ok, %{response | data: parsed_data}}

      {:error, error} ->
        {:error, error}
    end
  end

  @doc """
  Get available services for an order.

  ## Parameters

    * `config` - Travel configuration
    * `order_id` - The order ID

  ## Returns

    * `{:ok, %Travel.Types.DuffelResponse{data: [%Types.OfferAvailableService{}]}}` on success
    * `{:error, %Travel.Error{}}` on failure

  """
  @spec get_available_services(Travel.t(), String.t()) ::
          {:ok, Travel.Types.DuffelResponse.t()} | {:error, Travel.Error.t() | term()}
  def get_available_services(config, order_id) do
    path = "air/orders/#{order_id}/available_services"

    case Client.request(config, :get, path) do
      {:ok, response} ->
        parsed_data = Enum.map(response.data, &Types.parse_available_service/1)
        {:ok, %{response | data: parsed_data}}

      {:error, error} ->
        {:error, error}
    end
  end

  @doc """
  Add services to an order.

  ## Parameters

    * `config` - Travel configuration
    * `order_id` - The order ID
    * `params` - Service parameters:
      * `:payment` - Payment details
      * `:add_services` - List of services to add (with `id` and `quantity`)

  ## Returns

    * `{:ok, %Travel.Types.DuffelResponse{data: %Types.Order{}}}` on success
    * `{:error, %Travel.Error{}}` on failure

  """
  @spec add_services(Travel.t(), String.t(), map()) ::
          {:ok, Travel.Types.DuffelResponse.t()} | {:error, Travel.Error.t() | term()}
  def add_services(config, order_id, params) do
    path = "air/orders/#{order_id}/services"

    case Client.request(config, :post, path, params) do
      {:ok, response} ->
        parsed_data = Types.parse_order(response.data)
        {:ok, %{response | data: parsed_data}}

      {:error, error} ->
        {:error, error}
    end
  end
end
