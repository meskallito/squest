ExUnit.start()

{:ok, files} = File.ls("./test/support")

Enum.each files, fn(file) ->
  Code.require_file "support/#{file}", __DIR__
end

Application.put_env(:squest, :sqs_module, SQSMock)
SQSMock.start_link()
MessageHandlerMock.start_link()
RetryStrategyMock.start_link()

