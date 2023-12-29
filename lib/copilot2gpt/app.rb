require 'copilot2gpt/token'
require 'faraday'
require 'json'
require 'active_support/all'

MODEL = { "id": "gpt-4", "object": "model", "created": 1687882411, "owned_by": "openai" }

before do
  headers 'Access-Control-Allow-Origin' => '*',
          'Access-Control-Allow-Methods' => ['OPTIONS', 'GET', 'POST'],
          'Access-Control-Allow-Headers' => 'Content-Type'
  halt 200 if request.request_method == 'OPTIONS'
  @user_agent = request.env['HTTP_USER_AGENT'].to_s
  @chatbox = @user_agent.include?('chatbox')
end

get('/openai/models') do
  {
    object: 'list',
    data: [MODEL]
  }.to_json
end

post('/openai/chat/completions') do
  @mock_ai_gateway = true
  complete
end

post('/v1/chat/completions') do
  complete
end

def complete
  github_token = request.env['HTTP_AUTHORIZATION'].to_s.sub('Bearer ', '')
  if github_token.empty?
    halt 401, {'Content-Type' => 'application/json'}, {:message => 'Unauthorized'}.to_json
  end
  @copilot_token = Copilot2gpt::Token.get_copilot_token(github_token)
  content = params['content']
  url = "https://api.githubcopilot.com/chat/completions"
  chat_request = ChatRequest.with_default(content, JSON.parse(request.body.read, symbolize_names: true))
  conn = Faraday.new(url: url)

  if !chat_request.one_time_return
    stream do |response_stream|
      resp = conn.post do |req|
        req.headers = build_headers(@copilot_token)
        req.body = chat_request.to_json
        buffered_line = ""
        req.options.on_data = Proc.new do |chunk, overall_received_bytes, env|
          chunk.each_line do |line|
            line.chomp!
            next unless line.present?
            if line.start_with?("data: ")
              buffered_line = line
              message = JSON.parse(line.sub(/^data: /, '')) rescue next
            else
              buffered_line += line
              message = JSON.parse(buffered_line.sub(/^data: /, '')) rescue next
            end
            message = message.with_indifferent_access
            if @chatbox
              message[:choices].select! do |choice|
                choice.dig(:delta, :content)
              end
              next unless message[:choices].any?
            end
            if @mock_ai_gateway
              message.merge!(object: "chat.completion.chunk", model: "gpt-4")
            end
            message_json = message.to_json + "\n\n"
            message_json = "data: " + message_json unless @mock_ai_gateway
            response_stream << message_json
          end
        end
      end

      if resp.status != 200
        halt resp.status, {'Content-Type' => 'application/json'}, {:error => resp.body}.to_json
        return
      end
    end
  else
    resp = conn.post do |req|
      req.headers = build_headers(@copilot_token)
      req.body = chat_request.to_json
    end

    if resp.status != 200
      halt resp.status, {'Content-Type' => 'application/json'}, {:error => resp.body}.to_json
      return
    end

    buffer = ""
    res.body.each_line do |line|
      if line.start_with?("data: ")
        data = line.sub("data: ", "")
        obj = JSON.parse(data)
        if obj.key?("choices") && obj["choices"].is_a?(Array) && !obj["choices"].empty?
          choice = obj["choices"][0]
          if choice.is_a?(Hash) && choice.key?("delta") && choice["delta"].is_a?(Hash)
            delta = choice["delta"]
            if delta.key?("content") && delta["content"].is_a?(String)
              buffer += delta["content"]
            end
          end
        end
      end
    end
    return [200, {'Content-Type' => 'text/event-stream; charset=utf-8'}, buffer]
  end
end


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

def gen_hex_str(length)
  SecureRandom.hex(length / 2)
end

def build_headers(copilot_token)
  {
    "Authorization" => "Bearer #{copilot_token}",
    "X-Request-Id" => "#{gen_hex_str(8)}-#{gen_hex_str(4)}-#{gen_hex_str(4)}-#{gen_hex_str(4)}-#{gen_hex_str(12)}",
    "Vscode-Sessionid" => "#{gen_hex_str(8)}-#{gen_hex_str(4)}-#{gen_hex_str(4)}-#{gen_hex_str(4)}-#{gen_hex_str(25)}",
    "Vscode-Machineid" => gen_hex_str(64),
    "Editor-Version" => "vscode/1.83.1",
    "Editor-Plugin-Version" => "copilot-chat/0.8.0",
    "Openai-Organization" => "github-copilot",
    "Openai-Intent" => "conversation-panel",
    "Content-Type" => "text/event-stream; charset=utf-8",
    "User-Agent" => "GitHubCopilotChat/0.8.0",
    "Accept" => "*/*",
    "Accept-Encoding" => "gzip,deflate,br",
    "Connection" => "close"
  }
end