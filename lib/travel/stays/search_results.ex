defmodule Travel.Stays.SearchResults do
  @moduledoc """
  Fetch all rates for a search result.

  ## Endpoint

  `POST /stays/search_results/{id}/actions/fetch_all_rates`

  ## Examples

      config = Travel.new(access_token: "duffel_test_xxx")
      {:ok, response} = Travel.Stays.SearchResults.fetch_all_rates(config, "ser_123")

  @link https://duffel.com/docs/api/stays/search-results
  """

  alias Travel.Client
  alias Travel.Stays.Types

  @doc """
  Fetch all rates for the given search result.

  ## Parameters

    * `config` - Travel configuration
    * `search_result_id` - The ID of the search result

  ## Returns

    * `{:ok, %Travel.Types.DuffelResponse{data: %Types.StaysSearchResult{}}}` on success
    * `{:error, %Travel.Error{}}` on failure

  """
  @spec fetch_all_rates(Travel.t(), String.t()) ::
          {:ok, Travel.Types.DuffelResponse.t()} | {:error, Travel.Error.t() | term()}
  def fetch_all_rates(config, search_result_id) do
    path = "stays/search_results/#{search_result_id}/actions/fetch_all_rates"

    case Client.request(config, :post, path) do
      {:ok, response} ->
        parsed_data = Types.parse_search_result(response.data)
        {:ok, %{response | data: parsed_data}}

      {:error, error} ->
        {:error, error}
    end
  end
end
