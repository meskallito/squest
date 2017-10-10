defmodule MessageHandlerMock do
  use Squest.MessageHandler
  require Logger

  def start_link do
    Agent.start_link(
      fn ->
        %{
          handled_messages: []
        }
      end,
      name: __MODULE__
    )
  end

  def handle_message(message) do
    Logger.debug "handling message: #{inspect(message, pretty: true)}"

    Agent.update(
      __MODULE__,
      fn state ->
        update_in(state, [:handled_messages], &(&1 ++ [message]))
      end
    )
  end

  def handled_messages() do
    Agent.get(
      __MODULE__,
      fn state -> get_in(state, [:handled_messages]); end
    )
  end
end
