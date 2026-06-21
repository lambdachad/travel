defmodule Travel.Flights.OrderCancellations do
  @moduledoc """
  Create, retrieve, list, and confirm order cancellations.

  ## Endpoints

    * `POST /air/order_cancellations` - Create a cancellation
    * `GET /air/order_cancellations/{id}` - Get a cancellation
    * `GET /air/order_cancellations` - List cancellations
    * `POST /air/order_cancellations/{id}/actions/confirm` - Confirm a cancellation

  ## Examples

      # Create a cancellation
      {:ok, response} = Travel.Flights.OrderCancellations.create(%{
        order_id: "ord_123"
      })

      # Get a cancellation
      {:ok, response} = Travel.Flights.OrderCancellations.get("ore_123")

      # Confirm a cancellation
      {:ok, response} = Travel.Flights.OrderCancellations.confirm("ore_123")

  @link https://duffel.com/docs/api/order-cancellations
  """

  alias Travel.Client
  alias Travel.Flights.Types

  @doc """
  Create an order cancellation.

  ## Parameters

    * `params` - Cancellation parameters:
      * `:order_id` - (required) The order ID to cancel

  ## Returns

    * `{:ok, %Travel.Types.DuffelResponse{data: %Types.OrderCancellation{}}}` on success
    * `{:error, %Travel.Error{}}` on failure

  """
  @spec create(map()) ::
          {:ok, Travel.Types.DuffelResponse.t()} | {:error, Travel.Error.t() | term()}
  def create(params) do
    config = Travel.config!()

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

    * `cancellation_id` - The cancellation ID

  ## Returns

    * `{:ok, %Travel.Types.DuffelResponse{data: %Types.OrderCancellation{}}}` on success
    * `{:error, %Travel.Error{}}` on failure

  """
  @spec get(String.t()) ::
          {:ok, Travel.Types.DuffelResponse.t()} | {:error, Travel.Error.t() | term()}
  def get(cancellation_id) do
    config = Travel.config!()

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

    * `opts` - Optional parameters (`limit`, `before`, `after`, `order_id`)

  ## Returns

    * `{:ok, %Travel.Types.DuffelResponse{data: [%Types.OrderCancellation{}]}}` on success
    * `{:error, %Travel.Error{}}` on failure

  """
  @spec list(map() | nil) ::
          {:ok, Travel.Types.DuffelResponse.t()} | {:error, Travel.Error.t() | term()}
  def list(opts \\ nil) do
    config = Travel.config!()

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
  @spec stream(map() | nil) :: Enumerable.t()
  def stream(opts \\ nil) do
    config = Travel.config!()

    Client.stream(config, "air/order_cancellations", opts)
    |> Stream.map(fn response ->
      parsed_data = Enum.map(response.data, &Types.parse_order_cancellation/1)
      %{response | data: parsed_data}
    end)
  end

  @doc """
  Confirm a pending cancellation.

  ## Parameters

    * `cancellation_id` - The cancellation ID to confirm

  ## Returns

    * `{:ok, %Travel.Types.DuffelResponse{data: %Types.OrderCancellation{}}}` on success
    * `{:error, %Travel.Error{}}` on failure

  """
  @spec confirm(String.t()) ::
          {:ok, Travel.Types.DuffelResponse.t()} | {:error, Travel.Error.t() | term()}
  def confirm(cancellation_id) do
    config = Travel.config!()
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
