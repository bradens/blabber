# This is the agent used for persisting connected clients and chat messages.
defmodule Blabber.ChatServer do
  def start_link do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  @doc "Get a list of connected users"
  def users() do
    Agent.get(__MODULE__, fn users -> users end)
  end

  @doc "Add a connected client"
  def addUser(user) do
    Agent.update(__MODULE__, fn users -> Map.put(users, user.user_id, user) end)
  end

  @doc "Remove a connected client"
  def removeUser(user_id) do
    Agent.update(__MODULE__, fn users -> Map.delete(users, user_id) end)
  end

  @doc "Update a connected client"
  def updateUser(user) do
    addUser(user)
  end
end
