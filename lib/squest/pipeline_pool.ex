defmodule Squest.PipelinePool do
  use Supervisor

  alias Squest.Pipeline

  def start_link(_) do
    Supervisor.start_link(__MODULE__, [], name: :squest_pipeline_pool)
  end

  def start_pipeline(queue_path, message_handler, options) do
    Supervisor.start_child(:squest_pipeline_pool, [queue_path, message_handler, options])
  end

  def init(_) do
    supervise(
      [worker(Pipeline, [])],
      strategy: :simple_one_for_one
    )
  end
end
