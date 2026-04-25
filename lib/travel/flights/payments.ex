defmodule Travel.Flights.Payments do
  @moduledoc """
  Create, retrieve, and list payments for orders.

  ## Endpoints

    * `POST /air/payments` - Create a payment
    * `GET /air/payments/{id}` - Get a single payment
    * `GET /air/payments` - List payments

  ## Examples

      config = Travel.new(access_token: "duffel_test_xxx")

      # Create a payment
      {:ok, response} = Travel.Flights.Payments.create(config, %{
        order_id: "ord_123",
        payment: %{type: "balance", amount: "150.00", currency: "GBP"}
      })

      # Get a payment
      {:ok, response} = Travel.Flights.Payments.get(config, "pay_123")

      # List payments for an order
      {:ok, response} = Travel.Flights.Payments.list(config, %{order_id: "ord_123"})

  @link https://duffel.com/docs/api/payments
  """

  alias Travel.Client
  alias Travel.Flights.Types

  @doc """
  Create a payment for a pay-later order.

  ## Parameters

    * `config` - Travel configuration
    * `params` - Payment parameters:
      * `:order_id` - (required) The order ID to pay for
      * `:payment` - (required) Payment details (`type`, `amount`, `currency`)

  ## Returns

    * `{:ok, %Travel.Types.DuffelResponse{data: %Types.Payment{}}}` on success
    * `{:error, %Travel.Error{}}` on failure

  """
  @spec create(Travel.t(), map()) ::
          {:ok, Travel.Types.DuffelResponse.t()} | {:error, Travel.Error.t() | term()}
  def create(config, params) do
    case Client.request(config, :post, "air/payments", params) do
      {:ok, response} ->
        parsed_data = Types.parse_payment(response.data)
        {:ok, %{response | data: parsed_data}}

      {:error, error} ->
        {:error, error}
    end
  end

  @doc """
  Get a payment by ID.

  ## Parameters

    * `config` - Travel configuration
    * `payment_id` - The payment ID

  ## Returns

    * `{:ok, %Travel.Types.DuffelResponse{data: %Types.Payment{}}}` on success
    * `{:error, %Travel.Error{}}` on failure

  """
  @spec get(Travel.t(), String.t()) ::
          {:ok, Travel.Types.DuffelResponse.t()} | {:error, Travel.Error.t() | term()}
  def get(config, payment_id) do
    case Client.request(config, :get, "air/payments/#{payment_id}") do
      {:ok, response} ->
        parsed_data = Types.parse_payment(response.data)
        {:ok, %{response | data: parsed_data}}

      {:error, error} ->
        {:error, error}
    end
  end

  @doc """
  List payments with optional filtering and pagination.

  ## Parameters

    * `config` - Travel configuration
    * `opts` - Optional query parameters:
      * `:order_id` - (required) Filter by order ID
      * `:limit` - Results per page (max 200)
      * `:before` - Cursor for previous page
      * `:after` - Cursor for next page

  ## Returns

    * `{:ok, %Travel.Types.DuffelResponse{data: [%Types.Payment{}]}}` on success
    * `{:error, %Travel.Error{}}` on failure

  """
  @spec list(Travel.t(), map() | nil) ::
          {:ok, Travel.Types.DuffelResponse.t()} | {:error, Travel.Error.t() | term()}
  def list(config, opts \\ nil) do
    case Client.request(config, :get, "air/payments", nil, opts) do
      {:ok, response} ->
        parsed_data = Enum.map(response.data, &Types.parse_payment/1)
        {:ok, %{response | data: parsed_data}}

      {:error, error} ->
        {:error, error}
    end
  end
end
