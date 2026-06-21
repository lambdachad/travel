defmodule Travel.Flights.PartialOfferRequests do
  @moduledoc """
  Multi-step search partial offer requests.

  ## Endpoints

    * `POST /air/partial_offer_requests` - Create a partial offer request
    * `GET /air/partial_offer_requests/{id}` - Get a partial offer request
    * `GET /air/partial_offer_requests/{id}/fares` - Get fares by ID

  ## Examples

      # Create a partial offer request
      {:ok, response} = Travel.Flights.PartialOfferRequests.create(%{
        slices: [%{origin: "LHR", destination: "JFK", departure_date: "2025-06-01"}],
        passengers: [%{type: "adult"}]
      })

      # Get with selected partial offers
      {:ok, response} = Travel.Flights.PartialOfferRequests.get("por_123", %{
        selected_partial_offer: ["off_123"]
      })

  @link https://duffel.com/docs/api/partial-offer-requests
  """

  alias Travel.Client
  alias Travel.Flights.Types

  @doc """
  Create a partial offer request.

  ## Parameters

    * `params` - Partial offer request parameters
    * `opts` - Optional query parameters (`supplier_timeout`)

  ## Returns

    * `{:ok, %Travel.Types.DuffelResponse{data: %Types.OfferRequest{}}}` on success
    * `{:error, %Travel.Error{}}` on failure

  """
  @spec create(map(), map() | nil) ::
          {:ok, Travel.Types.DuffelResponse.t()} | {:error, Travel.Error.t() | term()}
  def create(params, opts \\ nil) do
    config = Travel.config!()

    query_params =
      if opts do
        Map.take(opts, [:supplier_timeout])
        |> Enum.reject(fn {_, v} -> is_nil(v) end)
        |> Map.new()
      else
        %{}
      end

    case Client.request(config, :post, "air/partial_offer_requests", params, query_params) do
      {:ok, response} ->
        parsed_data = Types.parse_offer_request(response.data)
        {:ok, %{response | data: parsed_data}}

      {:error, error} ->
        {:error, error}
    end
  end

  @doc """
  Get a partial offer request by ID.

  **DEPRECATED**: This endpoint will be removed in the next major version of the Duffel API.

  ## Parameters

    * `partial_offer_request_id` - The partial offer request ID
    * `opts` - Optional query parameters (`selected_partial_offer`)

  ## Returns

    * `{:ok, %Travel.Types.DuffelResponse{data: %Types.OfferRequest{}}}` on success
    * `{:error, %Travel.Error{}}` on failure

  """
  @deprecated "This endpoint will be removed in the next major version of the Duffel API"
  @spec get(String.t(), map() | nil) ::
          {:ok, Travel.Types.DuffelResponse.t()} | {:error, Travel.Error.t() | term()}
  def get(partial_offer_request_id, opts \\ nil) do
    config = Travel.config!()

    case Client.request(
           config,
           :get,
           "air/partial_offer_requests/#{partial_offer_request_id}",
           nil,
           opts
         ) do
      {:ok, response} ->
        parsed_data = Types.parse_offer_request(response.data)
        {:ok, %{response | data: parsed_data}}

      {:error, error} ->
        {:error, error}
    end
  end

  @doc """
  Get fares matching selected partial offers.

  **DEPRECATED**: This endpoint will be removed in the next major version of the Duffel API.

  ## Parameters

    * `partial_offer_request_id` - The partial offer request ID
    * `opts` - Optional query parameters (`selected_partial_offer`)

  ## Returns

    * `{:ok, %Travel.Types.DuffelResponse{data: %Types.OfferRequest{}}}` on success
    * `{:error, %Travel.Error{}}` on failure

  """
  @deprecated "This endpoint will be removed in the next major version of the Duffel API"
  @spec get_fares_by_id(String.t(), map() | nil) ::
          {:ok, Travel.Types.DuffelResponse.t()} | {:error, Travel.Error.t() | term()}
  def get_fares_by_id(partial_offer_request_id, opts \\ nil) do
    config = Travel.config!()
    path = "air/partial_offer_requests/#{partial_offer_request_id}/fares"

    case Client.request(config, :get, path, nil, opts) do
      {:ok, response} ->
        parsed_data = Types.parse_offer_request(response.data)
        {:ok, %{response | data: parsed_data}}

      {:error, error} ->
        {:error, error}
    end
  end
end
