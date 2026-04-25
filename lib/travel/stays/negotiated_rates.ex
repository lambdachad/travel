defmodule Travel.Stays.NegotiatedRates do
  @moduledoc """
  Create, retrieve, list, update, and delete negotiated rates.

  ## Endpoints

    * `POST /stays/negotiated_rates` - Create a negotiated rate
    * `GET /stays/negotiated_rates` - List negotiated rates
    * `GET /stays/negotiated_rates/{id}` - Get a negotiated rate
    * `PATCH /stays/negotiated_rates/{id}` - Update a negotiated rate
    * `DELETE /stays/negotiated_rates/{id}` - Delete a negotiated rate

  ## Examples

      config = Travel.new(access_token: "duffel_test_xxx")

      # Create a negotiated rate
      {:ok, response} = Travel.Stays.NegotiatedRates.create(config, %{
        accommodation_ids: ["acc_123"],
        display_name: "Corporate Rate",
        rate_access_code: "CORP123"
      })

      # List negotiated rates
      {:ok, response} = Travel.Stays.NegotiatedRates.list(config)

      # Get a negotiated rate
      {:ok, response} = Travel.Stays.NegotiatedRates.get(config, "nra_123")

      # Update a negotiated rate
      {:ok, response} = Travel.Stays.NegotiatedRates.update(config, "nra_123", %{
        display_name: "Updated Corporate Rate"
      })

      # Delete a negotiated rate
      {:ok, response} = Travel.Stays.NegotiatedRates.delete(config, "nra_123")

  @link https://duffel.com/docs/api/v2/negotiated-rates
  """

  alias Travel.Client

  @doc """
  Create a negotiated rate.

  ## Parameters

    * `config` - Travel configuration
    * `params` - Negotiated rate parameters:
      * `:accommodation_ids` - (required) List of accommodation IDs
      * `:display_name` - (required) Display name for the rate
      * `:rate_access_code` - (required) The access code for the rate

  ## Returns

    * `{:ok, %Travel.Types.DuffelResponse{data: map()}}` on success
    * `{:error, %Travel.Error{}}` on failure

  """
  @spec create(Travel.t(), map()) ::
          {:ok, Travel.Types.DuffelResponse.t()} | {:error, Travel.Error.t() | term()}
  def create(config, params) do
    Client.request(config, :post, "stays/negotiated_rates", params)
  end

  @doc """
  List negotiated rates with optional pagination.

  ## Parameters

    * `config` - Travel configuration
    * `opts` - Optional query parameters:
      * `:limit` - Results per page (max 200)
      * `:before` - Cursor for previous page
      * `:after` - Cursor for next page

  ## Returns

    * `{:ok, %Travel.Types.DuffelResponse{data: [map()]}}` on success
    * `{:error, %Travel.Error{}}` on failure

  """
  @spec list(Travel.t(), map() | nil) ::
          {:ok, Travel.Types.DuffelResponse.t()} | {:error, Travel.Error.t() | term()}
  def list(config, opts \\ nil) do
    Client.request(config, :get, "stays/negotiated_rates", nil, opts)
  end

  @doc """
  Get a negotiated rate by ID.

  ## Parameters

    * `config` - Travel configuration
    * `negotiated_rate_id` - The negotiated rate ID

  ## Returns

    * `{:ok, %Travel.Types.DuffelResponse{data: map()}}` on success
    * `{:error, %Travel.Error{}}` on failure

  """
  @spec get(Travel.t(), String.t()) ::
          {:ok, Travel.Types.DuffelResponse.t()} | {:error, Travel.Error.t() | term()}
  def get(config, negotiated_rate_id) do
    Client.request(config, :get, "stays/negotiated_rates/#{negotiated_rate_id}")
  end

  @doc """
  Update a negotiated rate.

  ## Parameters

    * `config` - Travel configuration
    * `negotiated_rate_id` - The negotiated rate ID
    * `params` - Update parameters:
      * `:accommodation_ids` - (optional) Updated list of accommodation IDs
      * `:display_name` - (optional) Updated display name
      * `:rate_access_code` - (optional) Updated access code

  ## Returns

    * `{:ok, %Travel.Types.DuffelResponse{data: map()}}` on success
    * `{:error, %Travel.Error{}}` on failure

  """
  @spec update(Travel.t(), String.t(), map()) ::
          {:ok, Travel.Types.DuffelResponse.t()} | {:error, Travel.Error.t() | term()}
  def update(config, negotiated_rate_id, params) do
    Client.request(config, :patch, "stays/negotiated_rates/#{negotiated_rate_id}", params)
  end

  @doc """
  Delete a negotiated rate.

  ## Parameters

    * `config` - Travel configuration
    * `negotiated_rate_id` - The negotiated rate ID

  ## Returns

    * `{:ok, %Travel.Types.DuffelResponse{}}` on success
    * `{:error, %Travel.Error{}}` on failure

  """
  @spec delete(Travel.t(), String.t()) ::
          {:ok, Travel.Types.DuffelResponse.t()} | {:error, Travel.Error.t() | term()}
  def delete(config, negotiated_rate_id) do
    Client.request(config, :delete, "stays/negotiated_rates/#{negotiated_rate_id}")
  end
end
