#!/usr/bin/env ruby
# frozen_string_literal: true

require 'openssl'
require 'csv'
require 'zlib'
require 'rspec/autorun'
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

    # read csv
    filestring = File.read('./foo.csv')

    # compress csv
    compressed = Zlib::Deflate.deflate(filestring)

    # encrypt csv
    # load byte array
    # send csv
    #
    # get csv
    # unload byte array: extract key and IV, decrypt key
    # decrypt csv using key
    # uncompress csv
    # write csv
    # ensure output is the same

    # TODO: does endianess matter?
    # TODO: are the key and iv lengths byte arrays themselves?
    #       If so, how would those be encoded? I can render the numbers into
    #       ASCII then provide the hex code for the ASCII caracters. Should
    #       these be in decimal or hex? In short, with an IV length of 16, if
    #       I did a binary dump (for example, using od), what would I expect
    #       to see?
    bytes = []

    # For the following, https://ruby-doc.org/core-3.0.0/Array.html#method-i-pack:
    # Some examples: https://idiosyncratic-ruby.com/4-what-the-pack.html
    # 3.2.0 :036 > [16].pack("C").ord
    #  => 16
    #  3.2.0 :037 > [16].pack("C")
    #   => "\x10"
    #  3.2.0 :038 > [32].pack("C")
    #   => " "
    #  3.2.0 :039 > [32].pack("C").ord
    #   => 32
    #  3.2.0 :040 >
    bytes << key.size.to_s
    bytes << iv.size.to_s
    # Using += is probably not performant.
    bytes += encrypted_key.bytes
    bytes += iv.bytes
    # binding.irb
    bytes
  end

  def compress
    Zlib::Deflate.deflate(File.read(@csv_file))
  end

  def cipher
    @cipher ||= OpenSSL::Cipher.new('aes-256-cbc')
  end

  # TODO: ask about this being the same key which is used for signing.
  # TODO: encrypt this with the RSA private key.
  def encrypted_key
    encryption_key.private_encrypt(key)
  end

  def encryption_key
    OpenSSL::PKey::RSA.new(ENV.fetch('JWT_DEMO_PRIVATE_KEY', nil))
  end

  def key
    @key ||= cipher.random_key
  end

  def iv
    @iv ||= cipher.random_iv
  end
end

# We have to do this because DATA is an IO stream,
# and reading it will advance the file pointer. But
# rewinding DATA sets the file pointer back to 0, which
# points at the beginning of the source file, that is,
# the beginning of this script, which is inconvenient.
# So we set a constant with the value of the first DATA.read.
CSV_DATA = DATA.read

# rubocop:disable Metrics/BlockLength
RSpec.describe Payload do
  let(:filename) { './foo.csv' }

  subject(:payload) { Payload.new(filename) }

  before do
    RsaKey.create_and_write_rsa_pem_keys
    RsaKey.set_envvars
  end

  example 'instantiates' do
    # puts "class OpenSSL::PKCS7: #{OpenSSL::PKCS7.methods}"
    expect(payload).to_not be nil
  end

  describe '#create' do
    it 'gets bytes' do
      payload = Payload.new('foo').create

      expect(payload.size).to be 274
    end
  end

  describe 'file' do
    example 'read DATA as file' do # and write to string.
      # This reads in the whole file as a string.
      file = File.read('./foo.csv')
      puts file.class

      # I can probably use DATA.read for string comparison with the
      # decrypted, uncompressed file.
      # puts DATA.read
    end

    example 'compare file with DATA' do
      file = File.read('./foo.csv')
      data = CSV_DATA
      expect(file).to eq data
    end

    example 'compare compressed files' do
      # https://docs.ruby-lang.org/en/master/Zlib.html
      data = CSV_DATA
      data_compressed = Zlib::Deflate.deflate(data)

      expect(payload.compress).to eq data_compressed
      # TODO: now inflate both and check.
    end

    example 'compressed and encrypted' do
      compressed = payload.compress
      cipher = OpenSSL::Cipher.new('aes-256-cbc')
      cipher.encrypt
      key = cipher.random_key
      iv = cipher.random_iv
      encrypted_csv = cipher.update(compressed) + cipher.final

      decipher = OpenSSL::Cipher.new('aes-256-cbc')
      decipher.decrypt
      decipher.key = key
      decipher.iv = iv

      plain = decipher.update(encrypted_csv) + decipher.final

      data = CSV_DATA
      data_compressed = Zlib::Deflate.deflate(data)

      expect(plain).to eq data_compressed
    end
  end

  describe 'csv' do
    xexample do
      csv = CSV.new(DATA.read, headers: true)
      csv.each { |row| puts row }
      # puts csv.to_s
      csv.rewind
      # binding.irb
      # st = CSV.generate(headers: true) do |csv_string|
      st = CSV.generate do |csv_string|
        # binding.irb
        # Can't read headers yet as line counter is 0 due to rewind.
        # The following just returns true.
        # csv_string << csv.headers

        # TODO: maybe write to Ruby Tempfile then look at the
        # resulting sring. What we want to do is set up a reversible
        # read, compress, encrypt, decrypt, uncompress loop and ensure
        # the output of the loop is identical to the input.
        #
        # Could also just read the DATA as a file and compare the string
        # to the Tempfile.
        csv.each do |line|
          puts "Line: #{line}"
          csv_string << line
        end
      end
      # binding.irb
      puts "st: #{st}"
    end
  end
end
# rubocop:enable Metrics/BlockLength

__END__
foo,bar
1,2
3,4
