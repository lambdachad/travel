defmodule Travel.Stays.Brands do
  @moduledoc """
  List and get hotel brands.

  ## Endpoints

    * `GET /stays/brands` - List all brands
    * `GET /stays/brands/{id}` - Get a brand

  ## Examples

      config = Travel.new(access_token: "duffel_test_xxx")

      # List all brands
      {:ok, response} = Travel.Stays.Brands.list(config)

      # Get a brand by ID
      {:ok, response} = Travel.Stays.Brands.get(config, "brd_123")

  @link https://duffel.com/docs/api/stays/brands
  """

  alias Travel.Client
  alias Travel.Stays.Types

  @doc """
  List all accommodation brands.

  ## Parameters

    * `config` - Travel configuration

  ## Returns

    * `{:ok, %Travel.Types.DuffelResponse{data: [%Types.StaysAccommodationBrand{}]}}` on success
    * `{:error, %Travel.Error{}}` on failure

  """
  @spec list(Travel.t()) ::
          {:ok, Travel.Types.DuffelResponse.t()} | {:error, Travel.Error.t() | term()}
  def list(config) do
    case Client.request(config, :get, "stays/brands") do
      {:ok, response} ->
        parsed_data = Enum.map(response.data, &parse_brand/1)
        {:ok, %{response | data: parsed_data}}

      {:error, error} ->
        {:error, error}
    end
  end

  @doc """
  Get a brand by ID.

  ## Parameters

    * `config` - Travel configuration
    * `brand_id` - The brand ID

  ## Returns

    * `{:ok, %Travel.Types.DuffelResponse{data: %Types.StaysAccommodationBrand{}}}` on success
    * `{:error, %Travel.Error{}}` on failure

  """
  @spec get(Travel.t(), String.t()) ::
          {:ok, Travel.Types.DuffelResponse.t()} | {:error, Travel.Error.t() | term()}
  def get(config, brand_id) do
    case Client.request(config, :get, "stays/brands/#{brand_id}") do
      {:ok, response} ->
        parsed_data = parse_brand(response.data)
        {:ok, %{response | data: parsed_data}}

      {:error, error} ->
        {:error, error}
    end
  end

  defp parse_brand(data) do
    %Types.StaysAccommodationBrand{
      id: data["id"],
      name: data["name"]
    }
  end
end
