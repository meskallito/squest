defmodule Squest.Pipeline.ConsumerSupervisor do
  use ConsumerSupervisor

  alias Squest.Pipeline.MessageConsumer

  require Logger

  def start_link(args) do
    ConsumerSupervisor.start_link(__MODULE__, args)
  end

  def init(args) do
    message_handler = Keyword.get(args, :message_handler)
    retry_strategy = Keyword.get(args, :retry_strategy)
    producers = Keyword.get(args, :producers)

    children = [
      worker(MessageConsumer, [message_handler, retry_strategy], restart: :temporary)
    ]

    "SQS consumer has started with the message_handler: #{inspect(message_handler)}, " <>
    "retry strategy: #{inspect(retry_strategy)}, " <>
    "and producer configuration: #{inspect(Keyword.values(producers) |> List.first)}" |> Logger.info

    {:ok, children, strategy: :one_for_one, subscribe_to: producers}
  end
end
