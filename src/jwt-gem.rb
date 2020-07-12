require 'pry-nav'
require 'jwt'
require 'base64'
require 'json'
require 'rspec'

# Example taken from jwt-ruby gem documentation
class JwtAuth
  SECRET = ENV['JWT_TEST_SECRET'] || 'secretkey'

  def payload
    {
      "loggedInAs" => "admin",
      "iat" => 1422779638
    }.to_json
  end
end

RSpec.describe JwtAuth do
  describe '#payload' do
    it 'returns payload in json format' do
      expected = "{\"loggedInAs\":\"admin\",\"iat\":1422779638}"
      expect(described_class.new.payload).to eq expected
    end
  end

  # Some lessons here:
  # * The gem takes native Ruby objects, there is no need to render json or string.
  # * The order of elements in the hash matters, because the encoding and signing
  #   depends on the order of elements in the resulting string.
  #
  # TODO: split this file into 3 parts:
  # 1. handrolled jwt construction using Wikipedia page
  # 2. JWT gem construction using jwt-ruby README on github
  # 3. rackup file implementing the gem-based scheme
  context 'jwt gem' do
    subject(:auth) { described_class.new }

    it 'matches handrolled values' do
      payload = {
        "loggedInAs": "admin",
        "iat": 1422779638
      }

      # This doesn't work:
      # jwt_token = JWT.encode("#{payload}", JwtAuth::SECRET, 'HS256', { typ: 'JWT' })

      # This works:
      jwt_token = JWT.encode(payload, JwtAuth::SECRET, 'HS256', { typ: 'JWT' })
      puts "jwt_token: #{jwt_token}"
      decoded = JWT.decode(jwt_token, JwtAuth::SECRET, true, { algorithm: 'HS256' })
      # binding.pry
      puts decoded
      # expect(jwt_token).to eq described_class.new.token
    end
  end
end