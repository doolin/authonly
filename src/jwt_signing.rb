#!/usr/bin/env ruby
# frozen_string_literal: true

# JWT auth in a single rails file

# Goal: emit a private key-signed JWT

# TODO: what needs to happen
# - Create a public/private key pair
# - Save the key pair to a local fi;e
# - Read the key files in as necessary for signing.
# - Write some sort of spec which can verify the signing works,

require 'jwt'
require 'rspec/autorun'

# Helper class for creating RSA keys
class RsaKey
  class << self
    def create_and_write_rsa_pem_keys
      key = OpenSSL::PKey::RSA.new(2048)
      File.write(private_name, key.to_pem)
      File.write(public_name, key.public_key.to_pem)
    end

    def set_envvars
      pubkey = File.read(public_name)
      ENV['JWT_DEMO_PUBLIC_KEY'] = pubkey

      privkey = File.read(private_name)
      ENV['JWT_DEMO_PRIVATE_KEY'] = privkey
    end

    def basename
      'jwt_demo'
    end

    def public_name
      "#{keys_path}/#{basename}.pem.pub"
    end

    def private_name
      "#{keys_path}/#{basename}.pem"
    end

    def keys_path
      'keys'
    end
  end
end

# Demo token
class JwtDemoToken
  ALGORITHM = 'RS256'

  # def initialize; end

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

    # TODO: create a test case for this.
    # OpenSSL::PKey::RSA.new('foobar', nil)
  end

  def header
    {
      'alg' => 'RS256',
      'typ' => 'JWT'
    }.to_json
  end

  def payload
    {
      'loggedInAs' => 'admin',
      'iat' => 1_422_779_638
    }.to_json
  end
end

RSpec.describe self do # rubocop:disable Metrics/BlockLength
  before do
    RsaKey.create_and_write_rsa_pem_keys
    RsaKey.set_envvars
    # puts ENV.fetch('JWT_DEMO_PUBLIC_KEY', nil)
    # puts ENV.fetch('JWT_DEMO_PRIVATE_KEY', nil)
  end

  example do
    token = JwtDemoToken.new.create
    _json = JwtDemoToken.decode(token)
    # binding.irb
    expect(JwtDemoToken.new).not_to be nil
  end

  example 'bogus public key' do
    # This works as we're generating a new key every time we run the test.
    bogus_key = <<~KEY
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
    ENV['JWT_DEMO_PUBLIC_KEY'] = bogus_key

    # puts bogus_key

    token = JwtDemoToken.new.create
    expect do
      JwtDemoToken.decode(token)
    end.to raise_error(JWT::VerificationError)
  end
end
