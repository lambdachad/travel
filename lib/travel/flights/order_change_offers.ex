defmodule Travel.Flights.OrderChangeOffers do
  @moduledoc """
  Get and list order change offers (PREVIEW).

  ## Endpoints

    * `GET /air/order_change_offers/{id}` - Get a change offer
    * `GET /air/order_change_offers` - List change offers

  ## Examples

      # Get a change offer
      {:ok, response} = Travel.Flights.OrderChangeOffers.get("oco_123")

      # List change offers
      {:ok, response} = Travel.Flights.OrderChangeOffers.list()

  @link https://duffel.com/docs/api/order-change-offers
  """

  alias Travel.Client
  alias Travel.Flights.Types

  @doc """
  Get a change offer by ID.

  ## Parameters

    * `offer_id` - The change offer ID

  ## Returns

    * `{:ok, %Travel.Types.DuffelResponse{data: %Types.OrderChangeOffer{}}}` on success
    * `{:error, %Travel.Error{}}` on failure

  """
  @spec get(String.t()) ::
          {:ok, Travel.Types.DuffelResponse.t()} | {:error, Travel.Error.t() | term()}
  def get(offer_id) do
    config = Travel.config!()

    case Client.request(config, :get, "air/order_change_offers/#{offer_id}") do
      {:ok, response} ->
        parsed_data = Types.parse_order_change_offer(response.data)
        {:ok, %{response | data: parsed_data}}

      {:error, error} ->
        {:error, error}
    end
  end

  @doc """
  List change offers with pagination.

  ## Parameters

    * `opts` - Optional query parameters:
      * `:order_change_request_id` - (required) The order change request ID
      * `:limit` - Results per page
      * `:before` - Cursor for previous page
      * `:after` - Cursor for next page
      * `:sort` - Sort order
      * `:max_connections` - Maximum connections

  ## Returns

    * `{:ok, %Travel.Types.DuffelResponse{data: [%Types.OrderChangeOffer{}]}}` on success
    * `{:error, %Travel.Error{}}` on failure

  """
  @spec list(map() | nil) ::
          {:ok, Travel.Types.DuffelResponse.t()} | {:error, Travel.Error.t() | term()}
  def list(opts \\ nil) do
    config = Travel.config!()

    case Client.request(config, :get, "air/order_change_offers", nil, opts) do
      {:ok, response} ->
        parsed_data = Enum.map(response.data, &Types.parse_order_change_offer/1)
        {:ok, %{response | data: parsed_data}}

      {:error, error} ->
        {:error, error}
    end
  end

  @doc """
  Stream all change offers with automatic pagination.

  ## Returns

    A `Stream` that yields `%Travel.Types.DuffelResponse{}` for each page.

  """
  @spec stream() :: Enumerable.t()
  def stream do
    config = Travel.config!()

    Client.stream(config, "air/order_change_offers")
    |> Stream.map(fn response ->
      parsed_data = Enum.map(response.data, &Types.parse_order_change_offer/1)
      %{response | data: parsed_data}
    end)
  end
end
