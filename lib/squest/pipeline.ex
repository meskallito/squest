defmodule Squest.Pipeline do
  use Supervisor

  alias Squest.Pipeline.MessageProducer
  alias Squest.Pipeline.ConsumerSupervisor
  alias Squest.ExponentialBackoff

  require Logger
  require IEx

  import Squest.MessageHandler, only: [valid_message_handler?: 1]
  import Squest.SQS, only: [queue_exists?: 1]

  @default_workers_count 4
  @sqs Application.fetch_env!(:squest, :sqs_module)

  defmodule NonExistentQueueError do
    defexception [:queue_name]

    def message(exception) do
      "#{inspect(exception.queue_name)} doesn't exist"
    end
  end

  defmodule BadMessageHandlerError do
    defexception [:message_handler]

    def message(exception) do
      "#{inspect(exception.message_handler)} doesn't implement behaviour"
    end
  end

  def start_link([queue_name, message_handler, options]) do
    start_link(queue_name, message_handler, options)
  end

  def start_link(queue_name, message_handler, options) do
    Supervisor.start_link(
      __MODULE__,
      [queue_name, message_handler, options],
      name: String.to_atom(queue_name <> "_pipeline")
    )
  end

  def init([queue_name, message_handler, options]) do
    producer_name = String.to_atom(queue_name <> "_producer")
    number_of_workers = Keyword.get(options, :workers_count, @default_workers_count)

    unless @sqs.queue_exists?(queue_name), do: raise %NonExistentQueueError{queue_name: queue_name}
    unless valid_message_handler?(message_handler) do
      raise %BadMessageHandlerError{message_handler: message_handler}
    end

    children = [
      worker(MessageProducer, [producer_name, queue_name, options]),
      worker(ConsumerSupervisor, [
        [
          producers: [{producer_name, max_demand: number_of_workers, min_demand: 1}],
          message_handler: message_handler,
          retry_strategy: ExponentialBackoff
        ]
      ]),
    ]

    supervise(children, strategy: :one_for_one)
  end
end

