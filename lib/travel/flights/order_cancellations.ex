defmodule Travel.Flights.OrderCancellations do
  @moduledoc """
  Create, retrieve, list, and confirm order cancellations.

  ## Endpoints

    * `POST /air/order_cancellations` - Create a cancellation
    * `GET /air/order_cancellations/{id}` - Get a cancellation
    * `GET /air/order_cancellations` - List cancellations
    * `POST /air/order_cancellations/{id}/actions/confirm` - Confirm a cancellation

  ## Examples

      config = Travel.new(access_token: "duffel_test_xxx")

      # Create a cancellation
      {:ok, response} = Travel.Flights.OrderCancellations.create(config, %{
        order_id: "ord_123"
      })

      # Get a cancellation
      {:ok, response} = Travel.Flights.OrderCancellations.get(config, "ore_123")

      # Confirm a cancellation
      {:ok, response} = Travel.Flights.OrderCancellations.confirm(config, "ore_123")

  @link https://duffel.com/docs/api/order-cancellations
  """

  alias Travel.Client
  alias Travel.Flights.Types

  @doc """
  Create an order cancellation.

  ## Parameters

    * `config` - Travel configuration
    * `params` - Cancellation parameters:
      * `:order_id` - (required) The order ID to cancel

  ## Returns

    * `{:ok, %Travel.Types.DuffelResponse{data: %Types.OrderCancellation{}}}` on success
    * `{:error, %Travel.Error{}}` on failure

  """
  @spec create(Travel.t(), map()) ::
          {:ok, Travel.Types.DuffelResponse.t()} | {:error, Travel.Error.t() | term()}
  def create(config, params) do
    case Client.request(config, :post, "air/order_cancellations", params) do
      {:ok, response} ->
        parsed_data = Types.parse_order_cancellation(response.data)
        {:ok, %{response | data: parsed_data}}

      {:error, error} ->
        {:error, error}
    end
  end

  @doc """
  Get a cancellation by ID.

  ## Parameters

    * `config` - Travel configuration
    * `cancellation_id` - The cancellation ID

  ## Returns

    * `{:ok, %Travel.Types.DuffelResponse{data: %Types.OrderCancellation{}}}` on success
    * `{:error, %Travel.Error{}}` on failure

  """
  @spec get(Travel.t(), String.t()) ::
          {:ok, Travel.Types.DuffelResponse.t()} | {:error, Travel.Error.t() | term()}
  def get(config, cancellation_id) do
    case Client.request(config, :get, "air/order_cancellations/#{cancellation_id}") do
      {:ok, response} ->
        parsed_data = Types.parse_order_cancellation(response.data)
        {:ok, %{response | data: parsed_data}}

      {:error, error} ->
        {:error, error}
    end
  end

  @doc """
  List order cancellations with optional filtering.

  ## Parameters

    * `config` - Travel configuration
    * `opts` - Optional parameters (`limit`, `before`, `after`, `order_id`)

  ## Returns

    * `{:ok, %Travel.Types.DuffelResponse{data: [%Types.OrderCancellation{}]}}` on success
    * `{:error, %Travel.Error{}}` on failure

  """
  @spec list(Travel.t(), map() | nil) ::
          {:ok, Travel.Types.DuffelResponse.t()} | {:error, Travel.Error.t() | term()}
  def list(config, opts \\ nil) do
    case Client.request(config, :get, "air/order_cancellations", nil, opts) do
      {:ok, response} ->
        parsed_data = Enum.map(response.data, &Types.parse_order_cancellation/1)
        {:ok, %{response | data: parsed_data}}

      {:error, error} ->
        {:error, error}
    end
  end

  @doc """
  Stream all cancellations with automatic pagination.

  ## Returns

    A `Stream` that yields `%Travel.Types.DuffelResponse{}` for each page.

  """
  @spec stream(Travel.t(), map() | nil) :: Enumerable.t()
  def stream(config, opts \\ nil) do
    Client.stream(config, "air/order_cancellations", opts)
    |> Stream.map(fn response ->
      parsed_data = Enum.map(response.data, &Types.parse_order_cancellation/1)
      %{response | data: parsed_data}
    end)
  end

  @doc """
  Confirm a pending cancellation.

  ## Parameters

    * `config` - Travel configuration
    * `cancellation_id` - The cancellation ID to confirm

  ## Returns

    * `{:ok, %Travel.Types.DuffelResponse{data: %Types.OrderCancellation{}}}` on success
    * `{:error, %Travel.Error{}}` on failure

  """
  @spec confirm(Travel.t(), String.t()) ::
          {:ok, Travel.Types.DuffelResponse.t()} | {:error, Travel.Error.t() | term()}
  def confirm(config, cancellation_id) do
    path = "air/order_cancellations/#{cancellation_id}/actions/confirm"

    case Client.request(config, :post, path) do
      {:ok, response} ->
        parsed_data = Types.parse_order_cancellation(response.data)
        {:ok, %{response | data: parsed_data}}

      {:error, error} ->
        {:error, error}
    end
  end
end
