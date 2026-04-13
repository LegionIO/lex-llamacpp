# frozen_string_literal: true

RSpec.describe Legion::Extensions::Llamacpp::Runners::Tokenize do
  let(:client_instance) { Legion::Extensions::Llamacpp::Client.new }
  let(:faraday_conn) { instance_double(Faraday::Connection) }

  before do
    allow(client_instance).to receive(:client).and_return(faraday_conn)
  end

  describe '#tokenize' do
    it 'tokenizes text content' do
      body = { 'tokens' => [1, 15_043, 3186] }
      response = instance_double(Faraday::Response, body: body, status: 200)
      allow(faraday_conn).to receive(:post).with('/tokenize', { content: 'Hello world' }).and_return(response)

      result = client_instance.tokenize(content: 'Hello world')
      expect(result[:result]['tokens']).to be_an(Array)
      expect(result[:status]).to eq(200)
    end
  end

  describe '#detokenize' do
    it 'detokenizes tokens back to text' do
      body = { 'content' => 'Hello world' }
      response = instance_double(Faraday::Response, body: body, status: 200)
      allow(faraday_conn).to receive(:post).with('/detokenize', { tokens: [1, 15_043, 3186] }).and_return(response)

      result = client_instance.detokenize(tokens: [1, 15_043, 3186])
      expect(result[:result]['content']).to eq('Hello world')
      expect(result[:status]).to eq(200)
    end
  end
end
