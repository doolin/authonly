# frozen_string_literal: true

require 'securerandom'

# Example for HTTP Digest
class DigestAuth
  def self.nonce
    SecureRandom.hex
  end

  puts nonce

  def call; end
end

run DigestAuth.new
