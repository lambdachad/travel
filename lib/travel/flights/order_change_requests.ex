defmodule Travel.Flights.OrderChangeRequests do
  @moduledoc """
  Create and retrieve order change requests (PREVIEW).

  ## Endpoints

    * `POST /air/order_change_requests` - Create a change request
    * `GET /air/order_change_requests/{id}` - Get a change request

  ## Examples

      config = Travel.new(access_token: "duffel_test_xxx")

      # Create a change request
      {:ok, response} = Travel.Flights.OrderChangeRequests.create(config, %{
        order_id: "ord_123",
        slices: %{
          add: [%{origin: "LHR", destination: "CDG", departure_date: "2025-07-01"}],
          remove: [%{slice_id: "sli_123"}]
        }
      })

  @link https://duffel.com/docs/api/order-change-requests
  """

  alias Travel.Client
  alias Travel.Flights.Types

  @doc """
  Create an order change request.

  ## Parameters

    * `config` - Travel configuration
    * `params` - Change request parameters:
      * `:order_id` - (required) The order ID to change
      * `:slices` - (required) Map with `add` and `remove` slice lists

  ## Returns

    * `{:ok, %Travel.Types.DuffelResponse{data: %Types.OrderChangeRequestResponse{}}}` on success
    * `{:error, %Travel.Error{}}` on failure

  """
  @spec create(Travel.t(), map()) ::
          {:ok, Travel.Types.DuffelResponse.t()} | {:error, Travel.Error.t() | term()}
  def create(config, params) do
    case Client.request(config, :post, "air/order_change_requests", params) do
      {:ok, response} ->
        parsed_data = Types.parse_order_change_request(response.data)
        {:ok, %{response | data: parsed_data}}

      {:error, error} ->
        {:error, error}
    end
  end

  @doc """
  Get a change request by ID.

  ## Parameters

    * `config` - Travel configuration
    * `change_request_id` - The change request ID

  ## Returns

    * `{:ok, %Travel.Types.DuffelResponse{data: %Types.OrderChangeRequestResponse{}}}` on success
    * `{:error, %Travel.Error{}}` on failure

  """
  @spec get(Travel.t(), String.t()) ::
          {:ok, Travel.Types.DuffelResponse.t()} | {:error, Travel.Error.t() | term()}
  def get(config, change_request_id) do
    case Client.request(config, :get, "air/order_change_requests/#{change_request_id}") do
      {:ok, response} ->
        parsed_data = Types.parse_order_change_request(response.data)
        {:ok, %{response | data: parsed_data}}

      {:error, error} ->
        {:error, error}
    end
  end
end
