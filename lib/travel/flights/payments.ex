defmodule Travel.Flights.Payments do
  @moduledoc """
  Create, retrieve, and list payments for orders.

  ## Endpoints

    * `POST /air/payments` - Create a payment
    * `GET /air/payments/{id}` - Get a single payment
    * `GET /air/payments` - List payments

  ## Examples

      # Create a payment
      {:ok, response} = Travel.Flights.Payments.create(%{
        order_id: "ord_123",
        payment: %{type: "balance", amount: "150.00", currency: "GBP"}
      })

      # Get a payment
      {:ok, response} = Travel.Flights.Payments.get("pay_123")

      # List payments for an order
      {:ok, response} = Travel.Flights.Payments.list(%{order_id: "ord_123"})

  @link https://duffel.com/docs/api/payments
  """

  alias Travel.Client
  alias Travel.Flights.Types

  @doc """
  Create a payment for a pay-later order.

  ## Parameters

    * `params` - Payment parameters:
      * `:order_id` - (required) The order ID to pay for
      * `:payment` - (required) Payment details (`type`, `amount`, `currency`)

  ## Returns

    * `{:ok, %Travel.Types.DuffelResponse{data: %Types.Payment{}}}` on success
    * `{:error, %Travel.Error{}}` on failure

  """
  @spec create(map()) ::
          {:ok, Travel.Types.DuffelResponse.t()} | {:error, Travel.Error.t() | term()}
  def create(params) do
    config = Travel.config!()

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

    * `payment_id` - The payment ID

  ## Returns

    * `{:ok, %Travel.Types.DuffelResponse{data: %Types.Payment{}}}` on success
    * `{:error, %Travel.Error{}}` on failure

  """
  @spec get(String.t()) ::
          {:ok, Travel.Types.DuffelResponse.t()} | {:error, Travel.Error.t() | term()}
  def get(payment_id) do
    config = Travel.config!()

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

    * `opts` - Optional query parameters:
      * `:order_id` - (required) Filter by order ID
      * `:limit` - Results per page (max 200)
      * `:before` - Cursor for previous page
      * `:after` - Cursor for next page

  ## Returns

    * `{:ok, %Travel.Types.DuffelResponse{data: [%Types.Payment{}]}}` on success
    * `{:error, %Travel.Error{}}` on failure

  """
  @spec list(map() | nil) ::
          {:ok, Travel.Types.DuffelResponse.t()} | {:error, Travel.Error.t() | term()}
  def list(opts \\ nil) do
    config = Travel.config!()

    case Client.request(config, :get, "air/payments", nil, opts) do
      {:ok, response} ->
        parsed_data = Enum.map(response.data, &Types.parse_payment/1)
        {:ok, %{response | data: parsed_data}}

      {:error, error} ->
        {:error, error}
    end
  end
end
