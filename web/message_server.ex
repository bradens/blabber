defmodule Blabber.MessageServer do
  def start_link do
    Agent.start_link(fn -> [] end, name: __MODULE__)
  end

  @doc "Get a list of messages with a max of the last 30"
  def messages() do
    Agent.get(__MODULE__, fn messages -> Enum.slice(messages, length(messages)-30, 30) end)
  end

  @doc "Add a message"
  def addMessage(message) do
    Agent.update(__MODULE__, fn messages -> messages ++ [message] end)
  end
end
