defmodule Travel.Flights.AirlineInitiatedChanges do
  @moduledoc """
  List, accept, and update airline-initiated changes.

  ## Endpoints

    * `GET /air/airline_initiated_changes` - List changes for an order
    * `POST /air/airline_initiated_changes/{id}/actions/accept` - Accept a change
    * `PATCH /air/airline_initiated_changes/{id}` - Update a change

  ## Examples

      config = Travel.new(access_token: "duffel_test_xxx")

      # List changes for an order
      {:ok, response} = Travel.Flights.AirlineInitiatedChanges.list(config, %{order_id: "ord_123"})

      # Accept a change
      {:ok, response} = Travel.Flights.AirlineInitiatedChanges.accept(config, "aic_123")

      # Update a change with action taken
      {:ok, response} = Travel.Flights.AirlineInitiatedChanges.update(config, "aic_123", %{
        action_taken: "accepted"
      })

  @link https://duffel.com/docs/api/airline-initiated-changes
  """

  alias Travel.Client
  alias Travel.Flights.Types

  @doc """
  List airline-initiated changes, optionally filtered by order.

  ## Parameters

    * `config` - Travel configuration
    * `opts` - Optional query parameters:
      * `:order_id` - Filter by order ID
      * `:limit` - Results per page (max 200)
      * `:before` - Cursor for previous page
      * `:after` - Cursor for next page

  ## Returns

    * `{:ok, %Travel.Types.DuffelResponse{data: [%Types.AirlineInitiatedChange{}]}}` on success
    * `{:error, %Travel.Error{}}` on failure

  """
  @spec list(Travel.t(), map() | nil) ::
          {:ok, Travel.Types.DuffelResponse.t()} | {:error, Travel.Error.t() | term()}
  def list(config, opts \\ nil) do
    case Client.request(config, :get, "air/airline_initiated_changes", nil, opts) do
      {:ok, response} ->
        parsed_data = Enum.map(response.data, &Types.parse_airline_initiated_change/1)
        {:ok, %{response | data: parsed_data}}

      {:error, error} ->
        {:error, error}
    end
  end

  @doc """
  Accept an airline-initiated change.

  ## Parameters

    * `config` - Travel configuration
    * `change_id` - The change ID to accept

  ## Returns

    * `{:ok, %Travel.Types.DuffelResponse{data: %Types.AirlineInitiatedChange{}}}` on success
    * `{:error, %Travel.Error{}}` on failure

  """
  @spec accept(Travel.t(), String.t()) ::
          {:ok, Travel.Types.DuffelResponse.t()} | {:error, Travel.Error.t() | term()}
  def accept(config, change_id) do
    path = "air/airline_initiated_changes/#{change_id}/actions/accept"

    case Client.request(config, :post, path) do
      {:ok, response} ->
        parsed_data = Types.parse_airline_initiated_change(response.data)
        {:ok, %{response | data: parsed_data}}

      {:error, error} ->
        {:error, error}
    end
  end

  @doc """
  Update an airline-initiated change with the action taken.

  ## Parameters

    * `config` - Travel configuration
    * `change_id` - The change ID
    * `params` - Update parameters:
      * `:action_taken` - (required) One of `"accepted"`, `"cancelled"`, `"changed"`

  ## Returns

    * `{:ok, %Travel.Types.DuffelResponse{data: %Types.AirlineInitiatedChange{}}}` on success
    * `{:error, %Travel.Error{}}` on failure

  """
  @spec update(Travel.t(), String.t(), map()) ::
          {:ok, Travel.Types.DuffelResponse.t()} | {:error, Travel.Error.t() | term()}
  def update(config, change_id, params) do
    case Client.request(config, :patch, "air/airline_initiated_changes/#{change_id}", params) do
      {:ok, response} ->
        parsed_data = Types.parse_airline_initiated_change(response.data)
        {:ok, %{response | data: parsed_data}}

      {:error, error} ->
        {:error, error}
    end
  end
end
