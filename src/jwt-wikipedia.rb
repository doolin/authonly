#!/usr/bin/env ruby
# frozen_string_literal: true

require 'openssl'
require 'base64'
require 'json'
require 'rspec'
require 'rspec/autorun'

# Example taken from https://en.wikipedia.org/wiki/JSON_Web_Token
class JwtAuth
  SECRET = ENV['JWT_TEST_SECRET'] || 'secretkey'

  def header
    {
      'alg' => 'HS256',
      'typ' => 'JWT'
    }.to_json
  end

  def encoded_header
    Base64.urlsafe_encode64(header)
  end

  def encoded_payload
    Base64.urlsafe_encode64(payload)
  end

  def payload
    {
      'loggedInAs' => 'admin',
      'iat' => 1_422_779_638
    }.to_json
  end

  def prefix
    "#{encoded_header}.#{encoded_payload}"
  end

  def signature
    OpenSSL::HMAC.digest(OpenSSL::Digest.new('SHA256'), JwtAuth::SECRET, prefix)
  end

  def encoded_signature
    Base64.urlsafe_encode64(signature, padding: false)
  end

  def token
    "#{prefix}.#{encoded_signature}"
  end
end

RSpec.describe JwtAuth do # rubocop:disable Metrics/BlockLength
  describe '#header' do
    it 'returns header in json format' do
      expected = '{"alg":"HS256","typ":"JWT"}'
      expect(described_class.new.header).to eq expected
    end
  end

  describe '#payload' do
    it 'returns payload in json format' do
      expected = '{"loggedInAs":"admin","iat":1422779638}'
      expect(described_class.new.payload).to eq expected
    end
  end

  describe '#prefix' do
    it 'returns prefix' do
      expected = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJsb2dnZWRJbkFzIjoiYWRtaW4iLCJpYXQiOjE0MjI3Nzk2Mzh9'
      expect(described_class.new.prefix).to eq expected
    end
  end

  describe '#signature' do
    xit 'returns raw signature' do
      expected = 'foo'
      expect(described_class.new.signature).to eq expected
    end
  end

  describe '#encoded_signature' do
    it 'returns encoded signature' do
      expected = 'gzSraSYS8EXBxLN_oWnFSRgCzcmJmMjLiuyu5CSpyHI'
      expect(described_class.new.encoded_signature).to eq expected
    end
  end

  describe '#token' do
    it 'returns the jwt' do
      # rubocop:disable Layout/LineLength
      expected = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJsb2dnZWRJbkFzIjoiYWRtaW4iLCJpYXQiOjE0MjI3Nzk2Mzh9.gzSraSYS8EXBxLN_oWnFSRgCzcmJmMjLiuyu5CSpyHI'
      # rubocop:enable Layout/LineLength
      expect(described_class.new.token).to eq expected
    end
  end

  context 'encoded header' do
    it 'encodes the header' do
      expected = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9'
      expect(described_class.new.encoded_header).to eq expected
    end
  end

  context 'encoded payload' do
    it 'encodes the payload' do
      expected = 'eyJsb2dnZWRJbkFzIjoiYWRtaW4iLCJpYXQiOjE0MjI3Nzk2Mzh9'
      expect(described_class.new.encoded_payload).to eq expected
    end
  end
end
