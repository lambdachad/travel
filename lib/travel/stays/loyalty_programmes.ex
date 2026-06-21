defmodule Travel.Stays.LoyaltyProgrammes do
  @moduledoc """
  List supported loyalty programmes for Duffel Stays.

  ## Endpoints

    * `GET /stays/loyalty_programmes` - List all loyalty programmes

  ## Examples

      {:ok, response} = Travel.Stays.LoyaltyProgrammes.list()

  @link https://duffel.com/docs/api/stays/loyalty-programmes
  """

  alias Travel.Client
  alias Travel.Stays.Types

  @doc """
  List all loyalty programmes supported by Duffel Stays.

  ## Returns

    * `{:ok, %Travel.Types.DuffelResponse{data: [%Types.StaysLoyaltyProgramme{}]}}` on success
    * `{:error, %Travel.Error{}}` on failure

  """
  @spec list() ::
          {:ok, Travel.Types.DuffelResponse.t()} | {:error, Travel.Error.t() | term()}
  def list do
    config = Travel.config!()

    case Client.request(config, :get, "stays/loyalty_programmes") do
      {:ok, response} ->
        parsed_data = Enum.map(response.data, &Types.parse_loyalty_programme/1)
        {:ok, %{response | data: parsed_data}}

      {:error, error} ->
        {:error, error}
    end
  end
end
