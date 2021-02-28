defmodule Rocketpay.Users.CreateTest do
  use Rocketpay.DataCase, async: true

  alias Rocketpay.User
  alias Rocketpay.Users.Create

  describe "call/1" do
    test "when all params are valid, return an user" do
      params = %{
        name: "Herbert",
        password: "112233",
        nickname: "herbert",
        email: "herbert@gmail.com",
        age: 28
      }

      {:ok, %User{id: user_id}} = Create.call(params)
      user = Repo.get(User, user_id)

      assert %User{name: "Herbert", age: 28, id: ^user_id} = user
    end

    test "when some params are invalid, return an error" do
      params = %{
        name: "Herbert",
        nickname: "herbert",
        email: "herbert@gmail.com",
        age: 15
      }

      {:error, changeset} = Create.call(params)

      expected_error = %{
        age: ["must be greater than or equal to 18"],
        password: ["can't be blank"]
      }

      assert expected_error == errors_on(changeset)
    end
  end
end
