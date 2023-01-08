#!/usr/bin/ruby
# frozen_string_literal: true

# Gist https://gist.github.com/doolin/54bcd357f2ade3f6b5ba737abcef684a
# forked as noted there.
#
# TODO: look up csp format. Maybe the following:
# - https://stackoverflow.com/questions/6598428/certificates-what-is-ksp-and-csp
# - https://learn.microsoft.com/en-us/windows/win32/secgloss/c-gly?redirectedfrom=MSDN#_security_cryptographic_service_provider_gly

require 'openssl'

TYPES = {
  6 => { magic: 'RSA1', private_key: false },
  7 => { magic: 'RSA2', private_key: true }
}.freeze

data = ARGV[0] ? File.binread(ARGV[0]) : $stdin.binmode.read
type, version, algo, magic, bits, rest = data.unpack('ccx2l<a4l<a*')

raise 'Unsupported type' unless (match = TYPES[type])
raise 'Wrong magic' if magic != match[:magic]

private_key = match[:private_key]

raise 'Unsupported version' if version != 2
raise 'Unsupported algorithm' if ((algo >> 9) & 15) != 2

fields = [32, bits]
fields.push(*[bits / 2] * 5, bits) if private_key

key = OpenSSL::PKey::RSA.new
key.e, key.n, key.p, key.q, key.dmp1, key.dmq1, key.iqmp, key.d = fields.map do |bits|
  size = (bits + 7) / 8
  raise 'Unexpected end of data reached' if rest.size < size

  OpenSSL::BN.new(rest.slice!(0, size).reverse!, 2)
end
raise 'Unexpected leftover data' unless rest.empty?

puts key.to_pem
