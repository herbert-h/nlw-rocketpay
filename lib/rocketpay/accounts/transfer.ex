defmodule Rocketpay.Accounts.Transfer do
  alias Ecto.Multi

  alias Rocketpay.Repo
  alias Rocketpay.Accounts.Operation
  alias Rocketpay.Accounts.Transfer.Response, as: TransferResponse

  def call(%{"from_account" => from_account_id, "to_account" => to_account_id, "value" => value}) do
    withdraw_params = build_params(from_account_id, value)
    deposit_params = build_params(to_account_id, value)

    Multi.new()
    |> Multi.merge(fn _changes -> Operation.call(withdraw_params, :withdraw) end)
    |> Multi.merge(fn _changes -> Operation.call(deposit_params, :deposit) end)
    |> run_transaction()
  end

  defp build_params(id, value), do: %{"account_id" => id, "value" => value}

  defp run_transaction(multi) do
    case Repo.transaction(multi) do
      {:error, _operation, reason, _changes} ->
        {:error, reason}

      {:ok, %{deposit: to_account, withdraw: from_account}} ->
        {:ok, TransferResponse.build(from_account, to_account)}
    end
  end
end
