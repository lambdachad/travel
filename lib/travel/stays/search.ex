defmodule Travel.Stays.Search do
  @moduledoc """
  Search for accommodations.

  ## Endpoint

  `POST /stays/search`

  ## Examples

      # Location-based search
      {:ok, response} = Travel.Stays.Search.search(%{
        location: %{
          geographic_coordinates: %{latitude: 51.5, longitude: -0.1},
          radius: 5
        },
        check_in_date: "2025-06-01",
        check_out_date: "2025-06-05",
        rooms: 1,
        guests: [%{type: "adult"}]
      })

      # Accommodation-based search
      {:ok, response} = Travel.Stays.Search.search(%{
        accommodation: %{
          ids: ["acc_0000AZ2OJbCJNYH4Y2Zm5j"],
          fetch_rates: true
        },
        check_in_date: "2025-06-01",
        check_out_date: "2025-06-05",
        rooms: 1,
        guests: [%{type: "adult"}]
      })

  @link https://duffel.com/docs/api/stays/search-stays
  """

  alias Travel.Client
  alias Travel.Stays.Types

  @doc """
  Search for accommodations.

  Accepts either location-based or accommodation-based search parameters.

  ## Parameters

    * `params` - Search parameters (see module docs for examples)

  ## Returns

    * `{:ok, %Travel.Types.DuffelResponse{data: %Types.StaysSearchResponse{}}}` on success
    * `{:error, %Travel.Error{}}` on failure

  """
  @spec search(map()) ::
          {:ok, Travel.Types.DuffelResponse.t()} | {:error, Travel.Error.t() | term()}
  def search(params) do
    config = Travel.config!()

    case Client.request(config, :post, "stays/search", params) do
      {:ok, response} ->
        parsed_data = Types.parse_search_response(response.data)
        {:ok, %{response | data: parsed_data}}

      {:error, error} ->
        {:error, error}
    end
  end
end
