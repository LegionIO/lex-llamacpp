# frozen_string_literal: true

RSpec.describe Legion::Extensions::Llamacpp::Runners::Health do
  let(:client_instance) { Legion::Extensions::Llamacpp::Client.new }
  let(:faraday_conn) { instance_double(Faraday::Connection) }

  before do
    allow(client_instance).to receive(:client).and_return(faraday_conn)
  end

  describe '#health' do
    it 'returns server health status' do
      body = { 'status' => 'ok' }
      response = instance_double(Faraday::Response, body: body, status: 200)
      allow(faraday_conn).to receive(:get).with('/health').and_return(response)

      result = client_instance.health
      expect(result[:result]['status']).to eq('ok')
      expect(result[:status]).to eq(200)
    end

    it 'returns non-200 status when server is loading' do
      body = { 'status' => 'loading model' }
      response = instance_double(Faraday::Response, body: body, status: 503)
      allow(faraday_conn).to receive(:get).with('/health').and_return(response)

      result = client_instance.health
      expect(result[:status]).to eq(503)
    end
  end
end
