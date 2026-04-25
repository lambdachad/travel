defmodule Travel.Flights.Payments do
  @moduledoc """
  Create payments for pay-later orders.

  ## Endpoints

    * `POST /air/payments` - Create a payment

  ## Examples

      config = Travel.new(access_token: "duffel_test_xxx")

      {:ok, response} = Travel.Flights.Payments.create(config, %{
        order_id: "ord_123",
        payment: %{type: "balance", amount: "150.00"}
      })

  @link https://duffel.com/docs/api/payments
  """

  alias Travel.Client
  alias Travel.Flights.Types

  @doc """
  Create a payment for a pay-later order.

  ## Parameters

    * `config` - Travel configuration
    * `params` - Payment parameters:
      * `:order_id` - (required) The order ID to pay for
      * `:payment` - (required) Payment details (`type`, `amount`, `currency`)

  ## Returns

    * `{:ok, %Travel.Types.DuffelResponse{data: %Types.Payment{}}}` on success
    * `{:error, %Travel.Error{}}` on failure

  """
  @spec create(Travel.t(), map()) ::
          {:ok, Travel.Types.DuffelResponse.t()} | {:error, Travel.Error.t() | term()}
  def create(config, params) do
    case Client.request(config, :post, "air/payments", params) do
      {:ok, response} ->
        parsed_data = Types.parse_payment(response.data)
        {:ok, %{response | data: parsed_data}}

      {:error, error} ->
        {:error, error}
    end
  end
end
