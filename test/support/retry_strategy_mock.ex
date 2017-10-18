defmodule RetryStrategyMock do
  @behaviour Squest.Behaviour.RetryStrategy
  require Logger

  def schedule_retry(sqs_message) do
    Agent.update(
      __MODULE__,
      fn state ->
        state ++ [sqs_message]
      end
    )
  end

  def incoming_messages() do
    Agent.get(
      __MODULE__,
      fn state -> state end
    )
  end

  def start_link do
    Agent.start_link(
      fn -> [] end,
      name: __MODULE__
    )
  end
end
