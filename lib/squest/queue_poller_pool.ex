defmodule Squest.QueuePollerPool do
  use Supervisor

  alias Squest.QueuePoller
  @process_name :squest_queue_poller_pool

  def start_link(_) do
    Supervisor.start_link(__MODULE__, [], name: @process_name)
  end

  def start_queue_poller(queue_path, message_handler, options) do
    Supervisor.start_child(@process_name, [queue_path, message_handler, options])
  end

  def init(_) do
    supervise(
      [worker(QueuePoller, [])],
      strategy: :simple_one_for_one
    )
  end
end
