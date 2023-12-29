module Copilot2GPT
  class ChatRequest
    attr_accessor :messages, :model, :temperature, :top_p, :n, :stream, :intent, :one_time_return

    def initialize(args)
      @messages = args[:messages]
      @model = args[:model]
      @temperature = args[:temperature]
      @top_p = args[:top_p]
      @n = args[:n]
      @stream = args[:stream]
      @intent = args[:intent]
      @one_time_return = args[:one_time_return]
    end

    def to_json
      {
        messages: @messages,
        model: @model,
        temperature: @temperature,
        top_p: @top_p,
        n: @n,
        stream: @stream,
        intent: @intent,
        one_time_return: @one_time_return
      }.to_json
    end

    class << self
      def with_default(content, params)
        default = {
          messages: [
            {"role" => "system", "content" => "\nYou are ChatGPT, a large language model trained by OpenAI.\nKnowledge cutoff: 2021-09\nCurrent model: gpt-4\nCurrent time: 2023/11/7 11: 39: 14\n"},
            {"role" => "user", "content" => content}
          ],
          model: "gpt-4", temperature: 0.5,
          top_p: 1, n: 1,
          stream: true, intent: true,
          one_time_return: false
        }.merge(params)
        new(default)
      end
    end
  end
end