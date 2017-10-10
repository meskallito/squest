defmodule Squest.PipelineTest do
  use ExUnit.Case, async: true

  alias Squest.Pipeline, as: P
  require Logger

  defmodule WrongHandler do
  end

  defmodule EmptyTestHandler do
    use Squest.MessageHandler
  end

  # TODO:
  #   test sucessful processing of the message
  #   test concurrent processing?
  #   test error processing
  #
  setup_all do
    SQSMock.register_queue("test_queue_name")
  end

  test "message hander that doesn't implement MessageHandlerBehaviour" do
    assert_raise Squest.Pipeline.BadMessageHandlerError, fn ->
      assert P.init(["test_queue_name", WrongHandler, []]) == {}
    end
  end

  test "queue doesn't exist" do
    assert_raise Squest.Pipeline.NonExistentQueueError, fn ->
      assert P.init(["non_existing_queue_name", EmptyTestHandler, []]) == {}
    end
  end
end
