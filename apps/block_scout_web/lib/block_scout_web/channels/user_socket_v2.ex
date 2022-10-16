defmodule BlockScoutWeb.UserSocketV2 do
  use Phoenix.Socket
  use Absinthe.Phoenix.Socket, schema: BlockScoutWeb.Schema
  alias Phoenix.Token

  channel("addresses:*", BlockScoutWeb.AddressChannel)
  channel("blocks:*", BlockScoutWeb.BlockChannel)
  channel("exchange_rate:*", BlockScoutWeb.ExchangeRateChannel)
  channel("rewards:*", BlockScoutWeb.RewardChannel)
  channel("transactions:*", BlockScoutWeb.TransactionChannel)
  channel("tokens:*", BlockScoutWeb.TokenChannel)

  def connect(%{"token" => token}, socket) do
    {:ok, verify_token(socket, token)}
  end

  def connect(_params, socket) do
    {:ok, socket}
  end

  def id(socket) do
    if socket.assigns[:user] do
      "user_socket:#{socket.assigns.user.id}"
    else
      nil
    end
  end

  defp verify_token(socket, token) do
    case Token.verify(socket, "user_auth", token, max_age: 3600 * 24) do
      {:ok, %{id: _, watchlist_id: _} = id_map} ->
        assign(socket, :user, id_map)

      _ ->
        socket
    end
  end
end
