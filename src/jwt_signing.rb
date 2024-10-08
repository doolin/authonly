#!/usr/bin/env ruby
# frozen_string_literal: true

# JWT auth in a single rails file

# Goal: emit a private key-signed JWT

# TODO: what needs to happen
# - Try signing the something with the public key such that
#   the private key decodes it.
require 'jwt'
require 'rspec/autorun'
require './rsa_key'

# Demo token
class JwtDemoToken
  ALGORITHM = 'RS256'
  TTL = 300

  def create
    JWT.encode(payload, secret_key, ALGORITHM)
  end

  def secret_key
    OpenSSL::PKey::RSA.new(ENV.fetch('JWT_DEMO_PRIVATE_KEY', nil))
  end

  def self.decode(token)
    JWT.decode(token, public_key, true, { algorithm: ALGORITHM })
  end

  def self.public_key
    OpenSSL::PKey::RSA.new(ENV.fetch('JWT_DEMO_PUBLIC_KEY', nil))
  end

  def time
    @time ||= Time.now.to_i
  end

  # TODO: add a real payload here with several
  # predefined claims and maybe a couple of custom claims.
  def payload
    {
      nbf: time,
      iat: time + TTL,
      loggedInAs: 'admin',
    }
  end
end

RSpec.describe self do # rubocop:disable Metrics/BlockLength
  before do
    RsaKey.create_and_write_rsa_pem_keys
    RsaKey.set_envvars
  end

  context 'with corrent RSA key' do
    it 'verifies correctly' do
      token = JwtDemoToken.new.create

      expect do
        JwtDemoToken.decode(token)
      end.not_to raise_error
    end

    example 'parses payload and header' do
      token = JwtDemoToken.new.create
      payload, header = *JwtDemoToken.decode(token)

      expect(payload['loggedInAs']).to eq 'admin'

      expected_header = { 'alg' => 'RS256' }
      expect(header).to eq expected_header
    end
  end

  context 'woth incorrect RSA key' do
    example 'bogus public key' do
      # This is bogus as we're generating a new key every time we run the test.
      ENV['JWT_DEMO_PUBLIC_KEY'] = <<~KEY
        -----BEGIN PUBLIC KEY-----
        MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAs7tqIh8t7/Apq4bMwMS+
        itZY/AJuKpTC4fDwLlDh5ESFTV+wJXAq2cydnK1PtgPOPMpekqtT4AygHuO6xWEO
        e9hMfcyye7R4g+/WUgem7iOQ3Y/kS8e0fmpw5cAQo8qAogd2ZzatmySIxyB1Zdzp
        8hqyd+K1f2WW5DiQyIomldlm1haVB2ZxC85yTVETiDMVCR+g3Y+poUIUO/KiTBDZ
        qbzhabcRYv5zKi8EkBwVAE+yyt79FmZOnD1VWuYpw6oH0hQJVtB441P2cFHpDpz2
        3VUJ7NynJiWoWAlXRIeOo4cl2pjb9jAwEBhxeXclIfcUDPNU+DcAd+ecUvaYZk+K
        UwIDAQAB
        -----END PUBLIC KEY-----
      KEY

      token = JwtDemoToken.new.create
      expect do
        JwtDemoToken.decode(token)
      end.to raise_error(JWT::VerificationError)
    end
  end
end
