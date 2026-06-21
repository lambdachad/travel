defmodule Travel.Stays.Quotes do
  @moduledoc """
  Create and retrieve quotes for stays.

  ## Endpoints

    * `POST /stays/quotes` - Create a quote
    * `GET /stays/quotes/{id}` - Get a quote

  ## Examples

      # Create a quote from a rate
      {:ok, response} = Travel.Stays.Quotes.create("rate_123")

      # Get a quote by ID
      {:ok, response} = Travel.Stays.Quotes.get("quo_123")

  @link https://duffel.com/docs/api/stays/quotes
  """

  alias Travel.Client
  alias Travel.Stays.Types

  @doc """
  Create a quote for the selected rate.

  ## Parameters

    * `rate_id` - The ID of the rate to quote

  ## Returns

    * `{:ok, %Travel.Types.DuffelResponse{data: %Types.StaysQuote{}}}` on success
    * `{:error, %Travel.Error{}}` on failure

  """
  @spec create(String.t()) ::
          {:ok, Travel.Types.DuffelResponse.t()} | {:error, Travel.Error.t() | term()}
  def create(rate_id) do
    config = Travel.config!()

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

    * `quote_id` - The ID of the quote

  ## Returns

    * `{:ok, %Travel.Types.DuffelResponse{data: %Types.StaysQuote{}}}` on success
    * `{:error, %Travel.Error{}}` on failure

  """
  @spec get(String.t()) ::
          {:ok, Travel.Types.DuffelResponse.t()} | {:error, Travel.Error.t() | term()}
  def get(quote_id) do
    config = Travel.config!()

    case Client.request(config, :get, "stays/quotes/#{quote_id}") do
      {:ok, response} ->
        parsed_data = Types.parse_quote(response.data)
        {:ok, %{response | data: parsed_data}}

      {:error, error} ->
        {:error, error}
    end
  end
end
