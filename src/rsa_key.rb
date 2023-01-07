# frozen_string_literal: true

# Helper class for creating RSA keys
# - Create a public/private key pair
# - Save the key pair to a local file
# - Read the key files in as necessary for signing.
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
