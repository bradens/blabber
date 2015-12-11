defmodule Blabber.RoomChannel do
  use Phoenix.Channel
  require Logger
  alias Blabber.ChatServer
  alias Blabber.MessageServer

  @doc """
  Authorize socket to subscribe and broadcast events on this channel & topic
  Possible Return Values
  `{:ok, socket}` to authorize subscription for channel for requested topic
  `:ignore` to deny subscription/broadcast on this channel
  for the requested topic
  """
  def join("rooms:lobby", message, socket) do
    Process.flag(:trap_exit, true)

    # Add the user to the chatserver, then return the list of all other users.
    ChatServer.addUser(%{ user_id: socket.assigns.user_id, username: socket.assigns.username })

    currentUser = Map.get(ChatServer.users(), socket.assigns.user_id)
    users = Map.delete(ChatServer.users(), socket.assigns.user_id)

    send(self, {:after_join, message})
    {:ok, %{currentUser: currentUser, users: users, messages: MessageServer.messages()}, socket}
  end

  def join("rooms:" <> _private_subtopic, _message, _socket) do
    {:error, %{reason: "unauthorized"}}
  end

  def handle_in("get:users", msg, socket) do
    users = Map.delete(ChatServer.users(), socket.assigns.user_id)
    {:reply, {:ok, users}, socket}
  end

  def handle_info({:after_join, msg}, socket) do
    broadcast! socket, "user:entered", %{user: msg["user"], user_id: socket.assigns.user_id}
    push socket, "join", %{status: "connected"}
    {:noreply, socket}
  end

  def handle_in("set:username", msg, socket) do
    broadcast_from! socket, "set:username", %{user: %{username: msg["username"], user_id: socket.assigns.user_id}}

    # Update our store with the new user
    user = %{ user_id: socket.assigns.user_id, username: msg["username"] }
    ChatServer.updateUser(user)

    {:reply, {:ok, %{msg: msg["username"], user_id: socket.assigns.user_id}}, socket}
  end

  def handle_in("new:msg", msg, socket) do
    # Update Messages in store
    MessageServer.addMessage(msg)

    broadcast! socket, "new:msg", %{user: msg["user"], body: msg["body"]}
    {:reply, {:ok, %{msg: msg["body"]}}, assign(socket, :user, msg["user"])}
  end

  def terminate(reason, _socket) do
    ChatServer.removeUser(_socket.assigns.user_id)
    broadcast! _socket, "user:left", %{user_id: _socket.assigns.user_id}
    :ok
  end
end
