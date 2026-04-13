# frozen_string_literal: true

RSpec.describe Legion::Extensions::Llamacpp::Client do
  subject(:client) { described_class.new }

  describe '#initialize' do
    it 'creates a client with default host' do
      expect(client.opts).to eq({ host: 'http://localhost:8080' })
    end

    it 'accepts a custom host' do
      custom = described_class.new(host: 'http://remote:8080')
      expect(custom.opts).to eq({ host: 'http://remote:8080' })
    end
  end

  describe '#client' do
    it 'returns a Faraday connection' do
      expect(client.client).to be_a(Faraday::Connection)
    end

    it 'uses the configured host' do
      conn = client.client
      expect(conn.url_prefix.to_s).to eq('http://localhost:8080/')
    end

    it 'allows host override' do
      conn = client.client(host: 'http://other:8080')
      expect(conn.url_prefix.to_s).to eq('http://other:8080/')
    end
  end

  describe '#streaming_client' do
    it 'returns a Faraday connection' do
      expect(client.streaming_client).to be_a(Faraday::Connection)
    end

    it 'uses the configured host' do
      conn = client.streaming_client
      expect(conn.url_prefix.to_s).to eq('http://localhost:8080/')
    end

    it 'allows host override' do
      conn = client.streaming_client(host: 'http://other:8080')
      expect(conn.url_prefix.to_s).to eq('http://other:8080/')
    end
  end

  describe 'runner inclusion' do
    it { is_expected.to respond_to(:chat) }
    it { is_expected.to respond_to(:chat_stream) }
    it { is_expected.to respond_to(:complete) }
    it { is_expected.to respond_to(:complete_stream) }
    it { is_expected.to respond_to(:embed) }
    it { is_expected.to respond_to(:list_models) }
    it { is_expected.to respond_to(:health) }
    it { is_expected.to respond_to(:tokenize) }
    it { is_expected.to respond_to(:detokenize) }
    it { is_expected.to respond_to(:list_slots) }
    it { is_expected.to respond_to(:erase_slot) }
  end
end
