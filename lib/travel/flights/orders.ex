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

      # Create an order
      {:ok, response} = Travel.Flights.Orders.create(%{
        selected_offers: ["off_123"],
        passengers: [%{
          given_name: "John",
          family_name: "Smith",
          born_on: "1990-01-01",
          gender: "m",
          title: "mr",
          email: "john@example.com",
          phone_number: "+442080160509"
        }],
        type: "instant"
      })

      # Get an order
      {:ok, response} = Travel.Flights.Orders.get("ord_123")

      # Update order metadata
      {:ok, response} = Travel.Flights.Orders.update("ord_123", %{
        metadata: %{"payment_intent_id" => "pit_123"}
      })

  @link https://duffel.com/docs/api/orders
  """

  alias Travel.Client
  alias Travel.Flights.Types

  @doc """
  Create an order from an offer.

  ## Parameters

    * `params` - Order parameters:
      * `:selected_offers` - (required) List of selected offer IDs (e.g., `["off_123"]`)
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
  @spec create(map()) ::
          {:ok, Travel.Types.DuffelResponse.t()} | {:error, Travel.Error.t() | term()}
  def create(params) do
    config = Travel.config!()

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

    * `order_id` - The order ID

  ## Returns

    * `{:ok, %Travel.Types.DuffelResponse{data: %Types.Order{}}}` on success
    * `{:error, %Travel.Error{}}` on failure

  """
  @spec get(String.t()) ::
          {:ok, Travel.Types.DuffelResponse.t()} | {:error, Travel.Error.t() | term()}
  def get(order_id) do
    config = Travel.config!()

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
  @spec list(map() | nil) ::
          {:ok, Travel.Types.DuffelResponse.t()} | {:error, Travel.Error.t() | term()}
  def list(opts \\ nil) do
    config = Travel.config!()

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
  @spec stream(map() | nil) :: Enumerable.t()
  def stream(opts \\ nil) do
    config = Travel.config!()

    Client.stream(config, "air/orders", opts)
    |> Stream.map(fn response ->
      parsed_data = Enum.map(response.data, &Types.parse_order/1)
      %{response | data: parsed_data}
    end)
  end

  @doc """
  Update an order's metadata.

  ## Parameters

    * `order_id` - The order ID
    * `params` - Update parameters (typically `metadata`)

  ## Returns

    * `{:ok, %Travel.Types.DuffelResponse{data: %Types.Order{}}}` on success
    * `{:error, %Travel.Error{}}` on failure

  """
  @spec update(String.t(), map()) ::
          {:ok, Travel.Types.DuffelResponse.t()} | {:error, Travel.Error.t() | term()}
  def update(order_id, params) do
    config = Travel.config!()

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

    * `order_id` - The order ID

  ## Returns

    * `{:ok, %Travel.Types.DuffelResponse{data: [%Types.OfferAvailableService{}]}}` on success
    * `{:error, %Travel.Error{}}` on failure

  """
  @spec get_available_services(String.t()) ::
          {:ok, Travel.Types.DuffelResponse.t()} | {:error, Travel.Error.t() | term()}
  def get_available_services(order_id) do
    config = Travel.config!()
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

    * `order_id` - The order ID
    * `params` - Service parameters:
      * `:payment` - Payment details
      * `:add_services` - List of services to add (with `id` and `quantity`)

  ## Returns

    * `{:ok, %Travel.Types.DuffelResponse{data: %Types.Order{}}}` on success
    * `{:error, %Travel.Error{}}` on failure

  """
  @spec add_services(String.t(), map()) ::
          {:ok, Travel.Types.DuffelResponse.t()} | {:error, Travel.Error.t() | term()}
  def add_services(order_id, params) do
    config = Travel.config!()
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
