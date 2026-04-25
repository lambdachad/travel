defmodule Travel.Flights.OrderChangeOffers do
  @moduledoc """
  Get and list order change offers (PREVIEW).

  ## Endpoints

    * `GET /air/order_change_offers/{id}` - Get a change offer
    * `GET /air/order_change_offers` - List change offers

  ## Examples

      config = Travel.new(access_token: "duffel_test_xxx")

      # Get a change offer
      {:ok, response} = Travel.Flights.OrderChangeOffers.get(config, "oco_123")

      # List change offers
      {:ok, response} = Travel.Flights.OrderChangeOffers.list(config)

  @link https://duffel.com/docs/api/order-change-offers
  """

  alias Travel.Client
  alias Travel.Flights.Types

  @doc """
  Get a change offer by ID.

  ## Parameters

    * `config` - Travel configuration
    * `offer_id` - The change offer ID

  ## Returns

    * `{:ok, %Travel.Types.DuffelResponse{data: %Types.OrderChangeOffer{}}}` on success
    * `{:error, %Travel.Error{}}` on failure

  """
  @spec get(Travel.t(), String.t()) ::
          {:ok, Travel.Types.DuffelResponse.t()} | {:error, Travel.Error.t() | term()}
  def get(config, offer_id) do
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

    * `config` - Travel configuration
    * `opts` - Optional pagination parameters (`limit`, `before`, `after`)

  ## Returns

    * `{:ok, %Travel.Types.DuffelResponse{data: [%Types.OrderChangeOffer{}]}}` on success
    * `{:error, %Travel.Error{}}` on failure

  """
  @spec list(Travel.t(), map() | nil) ::
          {:ok, Travel.Types.DuffelResponse.t()} | {:error, Travel.Error.t() | term()}
  def list(config, opts \\ nil) do
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
  @spec stream(Travel.t()) :: Enumerable.t()
  def stream(config) do
    Client.stream(config, "air/order_change_offers")
    |> Stream.map(fn response ->
      parsed_data = Enum.map(response.data, &Types.parse_order_change_offer/1)
      %{response | data: parsed_data}
    end)
  end
end
