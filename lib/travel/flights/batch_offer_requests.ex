defmodule Travel.Flights.BatchOfferRequests do
  @moduledoc """
  Long-polling batch offer requests.

  ## Endpoints

    * `POST /air/batch_offer_requests` - Create a batch offer request
    * `GET /air/batch_offer_requests/{id}` - Get a batch offer request

  ## Examples

      config = Travel.new(access_token: "duffel_test_xxx")

      # Create a batch offer request
      {:ok, response} = Travel.Flights.BatchOfferRequests.create(config, %{
        slices: [%{origin: "LHR", destination: "JFK", departure_date: "2025-06-01"}],
        passengers: [%{type: "adult"}]
      })

      # Poll for results
      {:ok, response} = Travel.Flights.BatchOfferRequests.get(config, "bor_123")

  @link https://duffel.com/docs/api/batch-offer-requests
  """

  alias Travel.Client
  alias Travel.Flights.Types

  @doc """
  Create a batch offer request.

  ## Parameters

    * `config` - Travel configuration
    * `params` - Batch offer request parameters (same as regular offer requests)
    * `opts` - Optional query parameters (`supplier_timeout`)

  ## Returns

    * `{:ok, %Travel.Types.DuffelResponse{data: %Types.CreateBatchOfferRequestResponse{}}}` on success
    * `{:error, %Travel.Error{}}` on failure

  """
  @spec create(Travel.t(), map(), map() | nil) ::
          {:ok, Travel.Types.DuffelResponse.t()} | {:error, Travel.Error.t() | term()}
  def create(config, params, opts \\ nil) do
    query_params =
      if opts do
        Map.take(opts, [:supplier_timeout])
        |> Enum.reject(fn {_, v} -> is_nil(v) end)
        |> Map.new()
      else
        %{}
      end

    case Client.request(config, :post, "air/batch_offer_requests", params, query_params) do
      {:ok, response} ->
        parsed_data = Types.parse_create_batch_offer_request(response.data)
        {:ok, %{response | data: parsed_data}}

      {:error, error} ->
        {:error, error}
    end
  end

  @doc """
  Get a batch offer request by ID (poll for available offers).

  ## Parameters

    * `config` - Travel configuration
    * `batch_offer_request_id` - The batch offer request ID

  ## Returns

    * `{:ok, %Travel.Types.DuffelResponse{data: %Types.BatchOfferRequest{}}}` on success
    * `{:error, %Travel.Error{}}` on failure

  """
  @spec get(Travel.t(), String.t()) ::
          {:ok, Travel.Types.DuffelResponse.t()} | {:error, Travel.Error.t() | term()}
  def get(config, batch_offer_request_id) do
    case Client.request(config, :get, "air/batch_offer_requests/#{batch_offer_request_id}") do
      {:ok, response} ->
        parsed_data = Types.parse_batch_offer_request(response.data)
        {:ok, %{response | data: parsed_data}}

      {:error, error} ->
        {:error, error}
    end
  end
end
