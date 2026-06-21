defmodule Travel.Flights.OrderChanges do
  @moduledoc """
  Create, retrieve, and confirm order changes.

  ## Endpoints

    * `POST /air/order_changes` - Create an order change
    * `GET /air/order_changes/{id}` - Get an order change
    * `POST /air/order_changes/{id}/actions/confirm` - Confirm an order change

  ## Examples

      # Create an order change
      {:ok, response} = Travel.Flights.OrderChanges.create(%{
        selected_order_change_offer: "oco_123"
      })

      # Confirm an order change
      {:ok, response} = Travel.Flights.OrderChanges.confirm("orc_123")

  @link https://duffel.com/docs/api/order-changes
  """

  alias Travel.Client
  alias Travel.Flights.Types

  @doc """
  Create an order change from a selected offer.

  ## Parameters

    * `params` - Change parameters:
      * `:selected_order_change_offer` - (required) The change offer ID

  ## Returns

    * `{:ok, %Travel.Types.DuffelResponse{data: %Types.OrderChange{}}}` on success
    * `{:error, %Travel.Error{}}` on failure

  """
  @spec create(map()) ::
          {:ok, Travel.Types.DuffelResponse.t()} | {:error, Travel.Error.t() | term()}
  def create(params) do
    config = Travel.config!()

    case Client.request(config, :post, "air/order_changes", params) do
      {:ok, response} ->
        parsed_data = Types.parse_order_change(response.data)
        {:ok, %{response | data: parsed_data}}

      {:error, error} ->
        {:error, error}
    end
  end

  @doc """
  Get an order change by ID.

  ## Parameters

    * `order_change_id` - The order change ID

  ## Returns

    * `{:ok, %Travel.Types.DuffelResponse{data: %Types.OrderChange{}}}` on success
    * `{:error, %Travel.Error{}}` on failure

  """
  @spec get(String.t()) ::
          {:ok, Travel.Types.DuffelResponse.t()} | {:error, Travel.Error.t() | term()}
  def get(order_change_id) do
    config = Travel.config!()

    case Client.request(config, :get, "air/order_changes/#{order_change_id}") do
      {:ok, response} ->
        parsed_data = Types.parse_order_change(response.data)
        {:ok, %{response | data: parsed_data}}

      {:error, error} ->
        {:error, error}
    end
  end

  @doc """
  Confirm a pending order change with payment.

  ## Parameters

    * `order_change_id` - The order change ID
    * `params` - (optional) Payment parameters:
      * `:payment` - Payment details (`amount`, `currency`, `type`, `three_d_secure_session_id`)

  ## Returns

    * `{:ok, %Travel.Types.DuffelResponse{data: %Types.OrderChange{}}}` on success
    * `{:error, %Travel.Error{}}` on failure

  """
  @spec confirm(String.t(), map() | nil) ::
          {:ok, Travel.Types.DuffelResponse.t()} | {:error, Travel.Error.t() | term()}
  def confirm(order_change_id, params \\ nil) do
    config = Travel.config!()
    path = "air/order_changes/#{order_change_id}/actions/confirm"

    case Client.request(config, :post, path, params) do
      {:ok, response} ->
        parsed_data = Types.parse_order_change(response.data)
        {:ok, %{response | data: parsed_data}}

      {:error, error} ->
        {:error, error}
    end
  end
end
