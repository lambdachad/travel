defmodule Travel.Flights.AirlineCredits do
  @moduledoc """
  Create, retrieve, and list airline credits.

  ## Endpoints

    * `POST /air/airline_credits` - Create an airline credit
    * `GET /air/airline_credits/{id}` - Get a single airline credit
    * `GET /air/airline_credits` - List airline credits

  ## Examples

      config = Travel.new(access_token: "duffel_test_xxx")

      # Create an airline credit
      {:ok, response} = Travel.Flights.AirlineCredits.create(config, %{
        order_id: "ord_123",
        amount: "100.00",
        currency: "GBP"
      })

      # Get an airline credit
      {:ok, response} = Travel.Flights.AirlineCredits.get(config, "acd_123")

      # List airline credits
      {:ok, response} = Travel.Flights.AirlineCredits.list(config, %{limit: 20})

  @link https://duffel.com/docs/api/airline-credits
  """

  alias Travel.Client
  alias Travel.Flights.Types

  @doc """
  Create an airline credit.

  ## Parameters

    * `config` - Travel configuration
    * `params` - Airline credit parameters:
      * `:order_id` - (required) The order ID
      * `:amount` - (required) The credit amount
      * `:currency` - (required) The currency code

  ## Returns

    * `{:ok, %Travel.Types.DuffelResponse{data: %Types.AirlineCredit{}}}` on success
    * `{:error, %Travel.Error{}}` on failure

  """
  @spec create(Travel.t(), map()) ::
          {:ok, Travel.Types.DuffelResponse.t()} | {:error, Travel.Error.t() | term()}
  def create(config, params) do
    case Client.request(config, :post, "air/airline_credits", params) do
      {:ok, response} ->
        parsed_data = Types.parse_airline_credit(response.data)
        {:ok, %{response | data: parsed_data}}

      {:error, error} ->
        {:error, error}
    end
  end

  @doc """
  Get an airline credit by ID.

  ## Parameters

    * `config` - Travel configuration
    * `credit_id` - The airline credit ID

  ## Returns

    * `{:ok, %Travel.Types.DuffelResponse{data: %Types.AirlineCredit{}}}` on success
    * `{:error, %Travel.Error{}}` on failure

  """
  @spec get(Travel.t(), String.t()) ::
          {:ok, Travel.Types.DuffelResponse.t()} | {:error, Travel.Error.t() | term()}
  def get(config, credit_id) do
    case Client.request(config, :get, "air/airline_credits/#{credit_id}") do
      {:ok, response} ->
        parsed_data = Types.parse_airline_credit(response.data)
        {:ok, %{response | data: parsed_data}}

      {:error, error} ->
        {:error, error}
    end
  end

  @doc """
  List airline credits with optional filtering and pagination.

  ## Parameters

    * `config` - Travel configuration
    * `opts` - Optional query parameters:
      * `:limit` - Results per page (max 200)
      * `:before` - Cursor for previous page
      * `:after` - Cursor for next page
      * `:order_id` - Filter by order ID

  ## Returns

    * `{:ok, %Travel.Types.DuffelResponse{data: [%Types.AirlineCredit{}]}}` on success
    * `{:error, %Travel.Error{}}` on failure

  """
  @spec list(Travel.t(), map() | nil) ::
          {:ok, Travel.Types.DuffelResponse.t()} | {:error, Travel.Error.t() | term()}
  def list(config, opts \\ nil) do
    case Client.request(config, :get, "air/airline_credits", nil, opts) do
      {:ok, response} ->
        parsed_data = Enum.map(response.data, &Types.parse_airline_credit/1)
        {:ok, %{response | data: parsed_data}}

      {:error, error} ->
        {:error, error}
    end
  end
end
