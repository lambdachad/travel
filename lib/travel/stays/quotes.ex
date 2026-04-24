defmodule Travel.Stays.Quotes do
  @moduledoc """
  Create and retrieve quotes for stays.

  ## Endpoints

    * `POST /stays/quotes` - Create a quote
    * `GET /stays/quotes/{id}` - Get a quote

  ## Examples

      config = Travel.new(access_token: "duffel_test_xxx")

      # Create a quote from a rate
      {:ok, response} = Travel.Stays.Quotes.create(config, "rate_123")

      # Get a quote by ID
      {:ok, response} = Travel.Stays.Quotes.get(config, "quo_123")

  @link https://duffel.com/docs/api/stays/quotes
  """

  alias Travel.Client
  alias Travel.Stays.Types

  @doc """
  Create a quote for the selected rate.

  ## Parameters

    * `config` - Travel configuration
    * `rate_id` - The ID of the rate to quote

  ## Returns

    * `{:ok, %Travel.Types.DuffelResponse{data: %Types.StaysQuote{}}}` on success
    * `{:error, %Travel.Error{}}` on failure

  """
  @spec create(Travel.t(), String.t()) ::
          {:ok, Travel.Types.DuffelResponse.t()} | {:error, Travel.Error.t() | term()}
  def create(config, rate_id) do
    case Client.request(config, :post, "stays/quotes", %{rate_id: rate_id}) do
      {:ok, response} ->
        parsed_data = Types.parse_quote(response.data)
        {:ok, %{response | data: parsed_data}}

      {:error, error} ->
        {:error, error}
    end
  end

  @doc """
  Get a quote by ID.

  ## Parameters

    * `config` - Travel configuration
    * `quote_id` - The ID of the quote

  ## Returns

    * `{:ok, %Travel.Types.DuffelResponse{data: %Types.StaysQuote{}}}` on success
    * `{:error, %Travel.Error{}}` on failure

  """
  @spec get(Travel.t(), String.t()) ::
          {:ok, Travel.Types.DuffelResponse.t()} | {:error, Travel.Error.t() | term()}
  def get(config, quote_id) do
    case Client.request(config, :get, "stays/quotes/#{quote_id}") do
      {:ok, response} ->
        parsed_data = Types.parse_quote(response.data)
        {:ok, %{response | data: parsed_data}}

      {:error, error} ->
        {:error, error}
    end
  end
end
