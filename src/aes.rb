#!/usr/bin/env ruby
# frozen_string_literal: true

require 'rspec/autorun'
require 'openssl'
require './rsa_key'

# Zip then Encrypt the file
#
# Ideally we would use asymmetric encryption for all transfers.
# But we are limited to files smaller than the key size.
#
# File encryption uses AES (symmetric encryption) with a randomly generated key for each file. The key for that
# file is encrypted using asymmetric encryption with the server's public key. This means only the server can
# decrypt the key needed to decrypt the file.
#
# ● Generate an AES Key and IV
# ● Note the _length_ of the AES Key and IV
# ● Zip the file (The file extension should be .zip)
# ● Encrypt the file using AES (The new file extension should be .zip.encrypted)
#   ○ KeySize: 256 bits
#   ○ Mode: CBC
#   ○ Padding: PKCS7
# ● Instantiate an RSA Crypto Service using the public key retrieved from the server
# ● Using the RSA Crypto Service (asymmetric encryption), encrypt the AES Key into a byte array
# ● Write the following as the contents of the encrypted file:
#   ○ Length of the encrypted AES Key (as byte array)
#   ○ Length of the AES IV (as byte array)
#   ○ Encrypted key bytes
#   ○ IV bytes
#   ○ AES encrypted file bytes

# Here's a good starting point: https://andyatkinson.com/blog/2018/01/22/encrypt-decrypt-ruby
# Ruby OpenSSL Cipher page; https://ruby-doc.org/stdlib-1.9.3/libdoc/openssl/rdoc/OpenSSL/Cipher.html
# https://www.youtube.com/watch?v=O4xNJsjtN6E
#  - Anki: Galois field syn. Finite field
#  - The AES operations apparently operate on the finite field 0..255, which is sixe 2^8. 256.

# cipher = OpenSSL::Cipher::AES.new(256, :CBC)

# puts key.size
# puts key.codepoints.size
# puts "IV class: #{iv.class}, IV size; #{iv.size}, bytes: #{iv.bytes}"

# puts OpenSSL::Cipher.ciphers

# ADD A SEQUENCE DIAGRAM

# Create the payload for the CQMsolution CSV API call.
class Payload
  attr_reader :csv_file

  # Hardcoding this as the details are specified by the
  # downstream service CQMsolution.
  CIPHER = 'aes-256-cbc'

  def initialize(csv_file)
    @csv_file = csv_file
  end

  def create
    cipher.encrypt

    bytes = []
    bytes << encrypted_key.bytes
  end

  def cipher
    @cipher ||= OpenSSL::Cipher.new('aes-256-cbc')
  end

  # TODO: encrypt this with the RSA private key.
  # TODO: ask about this being the same key which is used for signing.
  def encrypted_key
    key
  end

  def key
    @key ||= cipher.random_key
  end

  def iv
    @iv ||= cipher.random_iv
  end
end

RSpec.describe Payload do
  let(:filename) { 'foo' }

  subject(:payload) { Payload.new(filename) }

  example 'instantiates' do
    expect(payload).to_not be nil
  end

  describe '#create' do
    it 'gets bytes' do
      payload = Payload.new('foo').create

      expect(payload.size).to be 1
    end
  end
end
