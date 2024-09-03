# frozen_string_literal: true

require 'securerandom'

# Example for HTTP Digest
# Use this chatGPT session: https://chatgpt.com/c/9cac426e-1a79-43eb-95f3-4702fbd91932
class DigestAuth
  def self.nonce
    SecureRandom.hex
  end

  puts nonce

  def call; end
end

run DigestAuth.new
