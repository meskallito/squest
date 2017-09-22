defmodule Squest do
  @moduledoc """
  Documentation for Squest.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Squest.hello
      :world

  """
  alias Squest.PipelinePool

  def register_queue(queue_path, message_handler, options \\ []) do
    PipelinePool.start_pipeline(queue_path, message_handler, options)
  end
end
