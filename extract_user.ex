defmodule User do
  def extract_user(user) do
    with {:ok, login} <- extract_login(user),
         {:ok, email} <- extract_email(user),
         {:ok, password} <- extract_password(user) do
      {:ok, %{login: login, email: email, password: password}}
    end
  end

  defp extract_login(%{"login" => login}), do: {:ok, login}
  defp extract_login(_), do: {:error, "login missing"}

  defp extract_email(%{"email" => email}), do: {:ok, email}
  defp extract_email(_), do: {:error, "email missing"}

  defp extract_password(%{"password" => password}), do: {:ok, password}
  defp extract_password(_), do: {:error, "password missing"}
end

defmodule NewUser do
  @moduledoc "Improved user extraction that uses Enum"

  @doc "Extract user by checking that all required keys are provided"
  def extract_user(user) do
    case Enum.filter(
           ["login", "email", "password"],
           &(not Map.has_key?(user, &1))
         ) do
      [] ->
        {:ok,
         %{
           login: user["login"],
           email: user["email"],
           password: user["password"]
         }}

      missing_fields ->
        {:error, "missing fields: #{Enum.join(missing_fields, ", ")}"}
    end
  end
end
