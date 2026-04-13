# frozen_string_literal: true

RSpec.describe Legion::Extensions::Llamacpp::Helpers::Client do
  let(:test_class) do
    Class.new do
      include Legion::Extensions::Llamacpp::Helpers::Client
    end
  end
  let(:instance) { test_class.new }

  describe '#client' do
    it 'returns a Faraday connection' do
      expect(instance.client).to be_a(Faraday::Connection)
    end

    it 'defaults to localhost:8080' do
      conn = instance.client
      expect(conn.url_prefix.to_s).to eq('http://localhost:8080/')
    end

    it 'accepts a custom host' do
      conn = instance.client(host: 'http://remote-server:8080')
      expect(conn.url_prefix.to_s).to eq('http://remote-server:8080/')
    end

    it 'sets a 300 second timeout' do
      conn = instance.client
      expect(conn.options.timeout).to eq(300)
    end

    it 'sets a 10 second open timeout' do
      conn = instance.client
      expect(conn.options.open_timeout).to eq(10)
    end
  end

  describe '#streaming_client' do
    it 'returns a Faraday connection' do
      expect(instance.streaming_client).to be_a(Faraday::Connection)
    end

    it 'defaults to localhost:8080' do
      conn = instance.streaming_client
      expect(conn.url_prefix.to_s).to eq('http://localhost:8080/')
    end

    it 'accepts a custom host' do
      conn = instance.streaming_client(host: 'http://remote-server:8080')
      expect(conn.url_prefix.to_s).to eq('http://remote-server:8080/')
    end

    it 'sets a 300 second timeout' do
      conn = instance.streaming_client
      expect(conn.options.timeout).to eq(300)
    end
  end

  describe 'DEFAULT_HOST' do
    it 'is http://localhost:8080' do
      expect(Legion::Extensions::Llamacpp::Helpers::Client::DEFAULT_HOST).to eq('http://localhost:8080')
    end
  end
end
