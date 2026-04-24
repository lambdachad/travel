defmodule Travel do
  @moduledoc """
  Duffel API client for flights and stays.

  ## Configuration

  All API calls require a configuration struct created with `new/1`:

      config = Travel.new(access_token: "duffel_test_...")

  ### Options

    * `:access_token` - (required) Your Duffel API access token
    * `:base_url` - (optional) API base URL. Defaults to `"https://api.duffel.com"`
    * `:api_version` - (optional) API version header. Defaults to `"v2"`
    * `:debug` - (optional) Enable verbose logging. Defaults to `false`

  ## Usage

      config = Travel.new(access_token: "duffel_test_...")

      # Stays
      {:ok, response} = Travel.Stays.search(config, %{
        location: %{
          geographic_coordinates: %{latitude: 51.5, longitude: -0.1},
          radius: 5
        },
        check_in_date: "2025-06-01",
        check_out_date: "2025-06-05",
        rooms: 1,
        guests: [%{type: "adult"}]
      })

      # Flights
      {:ok, response} = Travel.Flights.OfferRequests.create(config, %{
        slices: [
          %{origin: "LHR", destination: "JFK", departure_date: "2025-06-01"}
        ],
        passengers: [%{type: "adult"}]
      })

  """

  use TypedStruct

  typedstruct enforce: true do
    @typedoc """
    Configuration for the Duffel API client.

    ## Fields

      * `:access_token` - Your Duffel API access token
      * `:base_url` - API base URL (default: `"https://api.duffel.com"`)
      * `:api_version` - API version (default: `"v2"`)
      * `:debug` - Enable verbose logging (default: `false`)
    """

    field(:access_token, String.t())
    field(:base_url, String.t(), default: "https://api.duffel.com")
    field(:api_version, String.t(), default: "v2")
    field(:debug, boolean(), default: false)
  end

  @doc """
  Creates a new Travel configuration struct.

  ## Options

    * `:access_token` - (required) Your Duffel API access token
    * `:base_url` - (optional) API base URL. Defaults to `"https://api.duffel.com"`
    * `:api_version` - (optional) API version header. Defaults to `"v2"`
    * `:debug` - (optional) Enable verbose logging. Defaults to `false`

  ## Examples

      iex> config = Travel.new(access_token: "duffel_test_xxx")
      iex> config.access_token
      "duffel_test_xxx"
      iex> config.base_url
      "https://api.duffel.com"

  """
  @spec new(keyword()) :: t()
  def new(opts) do
    struct!(__MODULE__, opts)
  end
end
