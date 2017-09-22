defmodule Squest.Pipeline.MessageProducer do
  use GenStage
  alias Squest.SQS
  require Logger

  @default_idle_timeout 5000

  def start_link(process_name, queue_name, options) do
    GenStage.start_link(
      __MODULE__,
      [
        queue_name,
        Keyword.get(options, :idle_timeout, @default_idle_timeout)
      ],
      name: process_name
    )
  end

  def init([queue_name, idle_timeout]) do
    state = %{
      demand: 0,
      queue_name: queue_name,
      idle_timeout: idle_timeout
    }

    Process.send_after(self(), :load_new_messages, idle_timeout)

    {:producer, state}
  end

  def handle_demand(incoming_demand, state) when incoming_demand > 0 do
    new_demand = state.demand + incoming_demand
    Logger.debug inspect("incoming_demand #{inspect(incoming_demand)} came; new_demand is #{inspect(new_demand)}")

    {:noreply, [], %{state | demand: new_demand}}
  end
  def handle_demand(incoming_demand, state) when incoming_demand == 0 do
    {:noreply, [], state}
  end

  def handle_info(:load_new_messages, %{demand: 0} = state) do
    Logger.debug inspect("skip loading with zero demand")
    schedule_next_hit(0, 0, state.idle_timeout)

    {:noreply, [], state}
  end

  def handle_info(:load_new_messages, %{queue_name: queue_name, demand: demand} = state) do
    Logger.debug inspect("try to load #{demand} messages")

    sqs_messages = SQS.receive_messages(queue_name, demand)
    loaded_messages_count = Enum.count(sqs_messages)

    schedule_next_hit(loaded_messages_count, demand, state.idle_timeout)

    Logger.debug inspect("sending new demand from load_new_messages: #{demand - loaded_messages_count}")

    {:noreply, sqs_messages, %{state | demand: demand - loaded_messages_count}}
  end

  defp schedule_next_hit(loaded_count, demand, _)
  when loaded_count > 0 or demand == 0 do
    Process.send(self(), :load_new_messages, [])
    Logger.debug("schedule immediate job")
  end

  defp schedule_next_hit(loaded_count, demand, idle_timeout) do
    Process.send_after(self(), :load_new_messages, idle_timeout)
    Logger.debug("schedule delayed job. timeout is #{idle_timeout}")
  end
end
