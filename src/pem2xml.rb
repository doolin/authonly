#!/usr/bin/ruby
# frozen_string_literal: true

require 'nokogiri'
require 'openssl'
require 'byebug'

# https://ruby-doc.org/stdlib-3.1.0/libdoc/openssl/rdoc/OpenSSL/PKey/RSA.html
# https://ruby-doc.org/stdlib-3.1.0/libdoc/openssl/rdoc/OpenSSL/PKey.html
# Go the other way: https://groups.google.com/g/mailing.openssl.users/c/8hAgyv4SiFY

# Create an MS RSA struct
class Pem2Xml
  def initialize(file_path)
    @file_path = file_path
  end

  def rsa_xml
    # key = OpenSSL::PKey::RSA.new(File.read($stdin))
    # key = OpenSSL::PKey::RSA.new(File.read('../../.ssh/cqm.pem'))

    key = OpenSSL::PKey::RSA.new(2048)

    key = key.public_key

    builder = Nokogiri::XML::Builder.new do |xml|
      xml.RSAKeyValue do
        xml.Modulus base64(key.n)
        xml.Exponent base64(key.e)
        if key.private?
          xml.D base64(key.d)
          xml.P base64(key.p)
          xml.Q base64(key.q)
          xml.DP base64(key.dmp1)
          xml.DQ base64(key.dmq1)
          xml.InverseQ base64(key.iqmp)
        end
      end
    end
    puts builder.to_xml
  end

  def base64(bn) # rubocop:disable Naming/MethodParameterName
    [bn.to_s(2)].pack('m0')
  end
end
