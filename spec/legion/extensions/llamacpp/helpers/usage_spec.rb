# frozen_string_literal: true

RSpec.describe Legion::Extensions::Llamacpp::Helpers::Usage do
  describe '.from_response' do
    it 'extracts usage from an OpenAI-format response body' do
      body = {
        'usage' => {
          'prompt_tokens'     => 26,
          'completion_tokens' => 259,
          'total_tokens'      => 285
        }
      }

      result = described_class.from_response(body)
      expect(result).to eq({
                             input_tokens:  26,
                             output_tokens: 259,
                             total_tokens:  285
                           })
    end

    it 'returns zero-filled hash when body is nil' do
      expect(described_class.from_response(nil)).to eq(described_class::EMPTY_USAGE)
    end

    it 'returns zero-filled hash when body is not a Hash' do
      expect(described_class.from_response('string')).to eq(described_class::EMPTY_USAGE)
    end

    it 'returns zero-filled hash when usage key is missing' do
      body = { 'model' => 'my-model', 'choices' => [] }
      expect(described_class.from_response(body)).to eq(described_class::EMPTY_USAGE)
    end

    it 'defaults missing keys to 0' do
      body = { 'usage' => { 'prompt_tokens' => 10 } }
      result = described_class.from_response(body)
      expect(result[:input_tokens]).to eq(10)
      expect(result[:output_tokens]).to eq(0)
      expect(result[:total_tokens]).to eq(0)
    end

    it 'handles a response with empty usage hash' do
      body = { 'usage' => {} }
      result = described_class.from_response(body)
      expect(result).to eq(described_class::EMPTY_USAGE)
    end
  end

  describe 'EMPTY_USAGE' do
    it 'is frozen' do
      expect(described_class::EMPTY_USAGE).to be_frozen
    end

    it 'contains all expected keys' do
      expect(described_class::EMPTY_USAGE.keys).to contain_exactly(
        :input_tokens, :output_tokens, :total_tokens
      )
    end
  end
end
