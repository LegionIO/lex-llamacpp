# frozen_string_literal: true

RSpec.describe Legion::Extensions::Llamacpp::Runners::Completions do
  let(:client_instance) { Legion::Extensions::Llamacpp::Client.new }
  let(:faraday_conn) { instance_double(Faraday::Connection) }
  let(:streaming_conn) { instance_double(Faraday::Connection) }
  let(:response) { instance_double(Faraday::Response, body: response_body, status: 200) }

  before do
    allow(client_instance).to receive(:client).and_return(faraday_conn)
    allow(client_instance).to receive(:streaming_client).and_return(streaming_conn)
  end

  describe '#complete' do
    let(:response_body) do
      {
        'id'      => 'cmpl-123',
        'object'  => 'text_completion',
        'model'   => 'my-model',
        'choices' => [{ 'index' => 0, 'text' => 'The sky is blue because of Rayleigh scattering.' }],
        'usage'   => { 'prompt_tokens' => 26, 'completion_tokens' => 259, 'total_tokens' => 285 }
      }
    end

    it 'sends a completion request' do
      allow(faraday_conn).to receive(:post).with('/v1/completions',
                                                 { model: 'my-model', prompt: 'Why is the sky blue?',
                                                   stream: false }).and_return(response)

      result = client_instance.complete(model: 'my-model', prompt: 'Why is the sky blue?')
      expect(result[:result]).to eq(response_body)
      expect(result[:status]).to eq(200)
    end

    it 'returns usage data' do
      allow(faraday_conn).to receive(:post).and_return(response)

      result = client_instance.complete(model: 'my-model', prompt: 'test')
      expect(result[:usage][:input_tokens]).to eq(26)
      expect(result[:usage][:output_tokens]).to eq(259)
      expect(result[:usage][:total_tokens]).to eq(285)
    end

    it 'includes optional parameters when provided' do
      allow(faraday_conn).to receive(:post).with('/v1/completions', {
                                                   model: 'my-model', prompt: 'Hello', stream: false,
                                                   temperature: 0.7, max_tokens: 100
                                                 }).and_return(response)

      result = client_instance.complete(model: 'my-model', prompt: 'Hello', temperature: 0.7, max_tokens: 100)
      expect(result[:status]).to eq(200)
    end

    it 'retries on timeout' do
      attempts = 0
      allow(faraday_conn).to receive(:post) do
        attempts += 1
        raise Faraday::TimeoutError if attempts < 2

        response
      end

      result = client_instance.complete(model: 'my-model', prompt: 'test')
      expect(result[:status]).to eq(200)
      expect(attempts).to eq(2)
    end
  end

  describe '#complete_stream' do
    let(:chunks) do
      [
        "data: {\"id\":\"cmpl-1\",\"choices\":[{\"index\":0,\"text\":\"The\"}]}\n\n",
        "data: {\"id\":\"cmpl-1\",\"choices\":[{\"index\":0,\"text\":\" sky\"}]}\n\n",
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
      result = client_instance.complete_stream(model: 'my-model', prompt: 'Why is the sky blue?')
      expect(result[:result]).to eq('The sky')
    end

    it 'returns usage with empty values when not provided in stream' do
      result = client_instance.complete_stream(model: 'my-model', prompt: 'test')
      expect(result[:usage]).to eq({ input_tokens: 0, output_tokens: 0, total_tokens: 0 })
    end

    it 'yields delta events to block' do
      events = []
      client_instance.complete_stream(model: 'my-model', prompt: 'test') { |e| events << e }
      deltas = events.select { |e| e[:type] == :delta }
      expect(deltas.map { |e| e[:text] }).to eq(['The', ' sky'])
    end

    it 'yields done event at end' do
      events = []
      client_instance.complete_stream(model: 'my-model', prompt: 'test') { |e| events << e }
      done = events.find { |e| e[:type] == :done }
      expect(done).not_to be_nil
    end

    it 'returns status 200' do
      result = client_instance.complete_stream(model: 'my-model', prompt: 'test')
      expect(result[:status]).to eq(200)
    end
  end
end
