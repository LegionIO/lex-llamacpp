# frozen_string_literal: true

RSpec.describe Legion::Extensions::Llamacpp::Runners::Slots do
  let(:client_instance) { Legion::Extensions::Llamacpp::Client.new }
  let(:faraday_conn) { instance_double(Faraday::Connection) }

  before do
    allow(client_instance).to receive(:client).and_return(faraday_conn)
  end

  describe '#list_slots' do
    it 'returns active inference slots' do
      body = [{ 'id' => 0, 'state' => 'idle' }, { 'id' => 1, 'state' => 'processing' }]
      response = instance_double(Faraday::Response, body: body, status: 200)
      allow(faraday_conn).to receive(:get).with('/slots').and_return(response)

      result = client_instance.list_slots
      expect(result[:result]).to be_an(Array)
      expect(result[:result].length).to eq(2)
      expect(result[:status]).to eq(200)
    end
  end

  describe '#erase_slot' do
    it 'erases a specific slot' do
      body = { 'status' => 'ok' }
      response = instance_double(Faraday::Response, body: body, status: 200)
      allow(faraday_conn).to receive(:post).with('/slots/0?action=erase').and_return(response)

      result = client_instance.erase_slot(id: 0)
      expect(result[:result]['status']).to eq('ok')
      expect(result[:status]).to eq(200)
    end
  end
end
