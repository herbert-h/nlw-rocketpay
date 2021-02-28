defmodule RocketpayWeb.AccountsControllerTest do
  use RocketpayWeb.ConnCase, async: true

  alias Rocketpay.{Account, User}

  describe "deposit/2" do
    setup %{conn: conn} do
      user_params = %{
        name: "Herbert",
        password: "112233",
        nickname: "herbert",
        email: "herbert@gmail.com",
        age: 28
      }

      {:ok, %User{account: %Account{id: account_id}}} = Rocketpay.create_user(user_params)

      conn = put_req_header(conn, "authorization", "Basic cXdlcnQ6enhjMTIz")

      {:ok, conn: conn, account_id: account_id}
    end

    test "when all params are valid, exec deposit", %{conn: conn, account_id: account_id} do
      params = %{"value" => "50.00"}

      response =
        conn
        |> post(Routes.accounts_path(conn, :deposit, account_id, params))
        |> json_response(:ok)

      assert %{
               "account" => %{"balance" => "50.00", "id" => _id},
               "message" => "Balance changed successfully"
             } = response
    end

    test "when there are invalid params, return error", %{conn: conn, account_id: account_id} do
      params = %{"value" => "banana"}

      response =
        conn
        |> post(Routes.accounts_path(conn, :deposit, account_id, params))
        |> json_response(:bad_request)

      expected_response = %{"message" => "Invalid deposit value"}

      assert expected_response == response
    end
  end
end
