# frozen_string_literal: true

RSpec.describe Legion::Extensions::Llamacpp::Runners::Chat do
  let(:client_instance) { Legion::Extensions::Llamacpp::Client.new }
  let(:faraday_conn) { instance_double(Faraday::Connection) }
  let(:streaming_conn) { instance_double(Faraday::Connection) }
  let(:response) { instance_double(Faraday::Response, body: response_body, status: 200) }
  let(:messages) { [{ 'role' => 'user', 'content' => 'Hello' }] }

  before do
    allow(client_instance).to receive(:client).and_return(faraday_conn)
    allow(client_instance).to receive(:streaming_client).and_return(streaming_conn)
  end

  describe '#chat' do
    let(:response_body) do
      {
        'id'      => 'chatcmpl-123',
        'object'  => 'chat.completion',
        'model'   => 'my-model',
        'choices' => [{ 'index' => 0, 'message' => { 'role' => 'assistant', 'content' => 'Hi there!' } }],
        'usage'   => { 'prompt_tokens' => 10, 'completion_tokens' => 5, 'total_tokens' => 15 }
      }
    end

    it 'sends a chat request' do
      allow(faraday_conn).to receive(:post).with('/v1/chat/completions',
                                                 { model: 'my-model', messages: messages, stream: false }).and_return(response)

      result = client_instance.chat(model: 'my-model', messages: messages)
      expect(result[:result]).to eq(response_body)
      expect(result[:status]).to eq(200)
    end

    it 'returns usage data' do
      allow(faraday_conn).to receive(:post).and_return(response)

      result = client_instance.chat(model: 'my-model', messages: messages)
      expect(result[:usage][:input_tokens]).to eq(10)
      expect(result[:usage][:output_tokens]).to eq(5)
      expect(result[:usage][:total_tokens]).to eq(15)
    end

    it 'includes tools when provided' do
      tools = [{ 'type' => 'function', 'function' => { 'name' => 'get_weather' } }]
      allow(faraday_conn).to receive(:post).with('/v1/chat/completions', {
                                                   model: 'my-model', messages: messages,
                                                   tools: tools, stream: false
                                                 }).and_return(response)

      result = client_instance.chat(model: 'my-model', messages: messages, tools: tools)
      expect(result[:status]).to eq(200)
    end

    it 'retries on connection failure' do
      attempts = 0
      allow(faraday_conn).to receive(:post) do
        attempts += 1
        raise Faraday::ConnectionFailed, 'refused' if attempts < 2

        response
      end

      result = client_instance.chat(model: 'my-model', messages: messages)
      expect(result[:status]).to eq(200)
      expect(attempts).to eq(2)
    end
  end

  describe '#chat_stream' do
    let(:chunks) do
      [
        "data: {\"id\":\"chatcmpl-1\",\"choices\":[{\"index\":0,\"delta\":{\"content\":\"Hi\"}}]}\n\n",
        "data: {\"id\":\"chatcmpl-1\",\"choices\":[{\"index\":0,\"delta\":{\"content\":\" there\"}}]}\n\n",
        "data: [DONE]\n\n"
      ]
    end

    before do
      allow(streaming_conn).to receive(:post) do |_path, _body, &request_block|
        req = double('request', options: double('options'))
        on_data_proc = nil
        allow(req.options).to receive(:on_data=) { |proc| on_data_proc = proc }
        request_block&.call(req)
        chunks.each { |chunk| on_data_proc&.call(chunk, chunk.length) }
        double('response')
      end
    end

    it 'accumulates streamed text' do
      result = client_instance.chat_stream(model: 'my-model', messages: messages)
      expect(result[:result]).to eq('Hi there')
    end

    it 'returns usage with empty values when not provided in stream' do
      result = client_instance.chat_stream(model: 'my-model', messages: messages)
      expect(result[:usage]).to eq({ input_tokens: 0, output_tokens: 0, total_tokens: 0 })
    end

    it 'yields delta events to block' do
      events = []
      client_instance.chat_stream(model: 'my-model', messages: messages) { |e| events << e }
      deltas = events.select { |e| e[:type] == :delta }
      expect(deltas.map { |e| e[:text] }).to eq(['Hi', ' there'])
    end

    it 'yields done event at end' do
      events = []
      client_instance.chat_stream(model: 'my-model', messages: messages) { |e| events << e }
      done = events.find { |e| e[:type] == :done }
      expect(done).not_to be_nil
    end

    it 'returns status 200' do
      result = client_instance.chat_stream(model: 'my-model', messages: messages)
      expect(result[:status]).to eq(200)
    end
  end
end
