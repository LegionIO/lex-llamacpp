# frozen_string_literal: true

RSpec.describe Legion::Extensions::Llamacpp::Runners::Models do
  let(:client_instance) { Legion::Extensions::Llamacpp::Client.new }
  let(:faraday_conn) { instance_double(Faraday::Connection) }

  before do
    allow(client_instance).to receive(:client).and_return(faraday_conn)
  end

  describe '#list_models' do
    it 'returns available models' do
      body = { 'object' => 'list', 'data' => [{ 'id' => 'my-model', 'object' => 'model' }] }
      response = instance_double(Faraday::Response, body: body, status: 200)
      allow(faraday_conn).to receive(:get).with('/v1/models').and_return(response)

      result = client_instance.list_models
      expect(result[:result]['data']).to be_an(Array)
      expect(result[:status]).to eq(200)
    end
  end
end
