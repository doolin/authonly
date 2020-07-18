require 'securerandom'

class DigestAuth

  def self.nonce
    SecureRandom.hex
  end

  puts nonce

  def call
  end
end

run DigestAuth.new