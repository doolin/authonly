#!/usr/bin/env ruby
# frozen_string_literal: true

require 'rspec/autorun'

# Very simple method demonstrating the economy of Ruby.
# Is this overkill? Maybe, but maybe not. Implementing
# this turned up an edge case.
#
# @params:
# - value is the header value, e.g., Basic dXNlcm5hbWUxOnBhc3N3b3Jk
#
# TODO: Handle edge case where Basic is not present in the value.
# request.headers["Authorization"]&.index('Basic') "fails" when
# value is empty with index zero, need to handle that case.
def extract_encoded(value)
  value&.sub(/Basic\s+/, '')
end

RSpec.describe self do
  describe '.extract_encoded' do
    context 'header and value is present' do
      example 'handles good formatting' do
        encoded = 'dXNlcm5hbWUxOnBhc3N3b3Jk'
        header = "Basic #{encoded}"

        expect(extract_encoded(header)).to eq encoded
      end

      example 'bad formatting' do
        encoded = 'dXNlcm5hbWUxOnBhc3N3b3Jk'
        header = "Basic                     #{encoded}"

        expect(extract_encoded(header)).to eq encoded
      end
    end

    context 'header/value nil' do
      example do
        result = extract_encoded(nil)

        expect(result).to be nil
      end
    end

    # TODO: figure out how to handle an edge case where the
    # expectation is Basic auth, but the reality is not.
    context 'not basic auth' do
      xexample 'edge case' do
        result = extract_encoded('random garbage')

        expect(result).to be nil
      end
    end

    context 'empty string' do
      xexample 'edge case' do
        result = extract_encoded('')

        expect(result).to be nil
      end
    end
  end
end
