defmodule Travel do
  @moduledoc """
  Duffel API client for flights and stays.

  ## Configuration

  Add to your `config/runtime.exs`:

      config :travel, access_token: System.get_env("DUFFEL_ACCESS_TOKEN")

  ### Options

    * `:access_token` - (required) Your Duffel API access token
    * `:base_url` - (optional) API base URL. Defaults to `"https://api.duffel.com"`
    * `:api_version` - (optional) API version header. Defaults to `"v2"`
    * `:debug` - (optional) Enable verbose logging. Defaults to `false`

  ## Usage

      # Stays
      {:ok, response} = Travel.Stays.Search.create(%{
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
      {:ok, response} = Travel.Flights.OfferRequests.create(%{
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
  Returns the Travel configuration from application environment.

  Reads from `Application.get_env(:travel, ...)` and returns a `%Travel{}` struct.

  Raises if `:access_token` is not configured.

  ## Examples

      # In config/runtime.exs:
      config :travel, access_token: System.get_env("DUFFEL_ACCESS_TOKEN")

      # Then anywhere in your app:
      Travel.config!()
      #=> %Travel{access_token: "duffel_test_...", base_url: "https://api.duffel.com", ...}

  """
  @spec config!() :: t()
  def config! do
    access_token =
      Application.get_env(:travel, :access_token) ||
        raise """
        Travel is not configured. Add to your config:

            config :travel, access_token: "your_duffel_access_token"
        """

    struct!(__MODULE__,
      access_token: access_token,
      base_url: Application.get_env(:travel, :base_url, "https://api.duffel.com"),
      api_version: Application.get_env(:travel, :api_version, "v2"),
      debug: Application.get_env(:travel, :debug, false)
    )
  end
end
