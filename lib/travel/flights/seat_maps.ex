defmodule Travel.Flights.SeatMaps do
  @moduledoc """
  Get seat maps for flight offers.

  ## Endpoints

    * `GET /air/seat_maps` - Get seat maps by offer ID

  ## Examples

      config = Travel.new(access_token: "duffel_test_xxx")

      {:ok, response} = Travel.Flights.SeatMaps.get(config, %{offer_id: "off_123"})

  @link https://duffel.com/docs/api/seat-maps
  """

  alias Travel.Client
  alias Travel.Flights.Types

  @doc """
  Get seat maps for an offer.

  ## Parameters

    * `config` - Travel configuration
    * `params` - Query parameters:
      * `:offer_id` - (required) The offer ID

  ## Returns

    * `{:ok, %Travel.Types.DuffelResponse{data: [%Types.SeatMap{}]}}` on success
    * `{:error, %Travel.Error{}}` on failure

  """
  @spec get(Travel.t(), map()) ::
          {:ok, Travel.Types.DuffelResponse.t()} | {:error, Travel.Error.t() | term()}
  def get(config, params) do
    case Client.request(config, :get, "air/seat_maps", nil, params) do
      {:ok, response} ->
        parsed_data = Enum.map(response.data, &Types.parse_seat_map/1)
        {:ok, %{response | data: parsed_data}}

      {:error, error} ->
        {:error, error}
    end
  end
end
