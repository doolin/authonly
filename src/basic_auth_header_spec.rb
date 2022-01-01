#!/usr/bin/env ruby
# frozen_string_literal: true

require 'rspec/autorun'

# https://www.honeybadger.io/blog/ruby-exception-vs-standarderror-whats-the-difference/
class BasicAuthError < StandardError
  DEFAULT_MESSAGE = 'value given for auth header is malformed'
  def message
    DEFAULT_MESSAGE
  end
end

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
  regex = /\ABasic\s+/
  raise BasicAuthError unless value&.match?(regex)

  value&.sub(regex, '')
end

RSpec.describe self do
  describe '.extract_encoded' do
    let(:encoded) { 'dXNlcm5hbWUxOnBhc3N3b3Jk' }

    context 'succeeds when header and value is present' do
      example 'with single whitespace formatting' do
        header = "Basic #{encoded}"

        expect(extract_encoded(header)).to eq encoded
      end

      example 'with multiple whitespace formatting' do
        header = "Basic                     #{encoded}"

        expect(extract_encoded(header)).to eq encoded
      end
    end

    context 'fails when auth header value' do
      example 'is nil' do
        expect { extract_encoded(nil) }
          .to raise_error(BasicAuthError, BasicAuthError::DEFAULT_MESSAGE)
      end

      example 'is not basic auth' do
        expect { extract_encoded('random garbage') }
          .to raise_error(BasicAuthError, BasicAuthError::DEFAULT_MESSAGE)
      end

      example 'is an empty string' do
        expect { extract_encoded('') }
          .to raise_error(BasicAuthError, BasicAuthError::DEFAULT_MESSAGE)
      end

      # TODO: show how this can be more liberal by adjusting the regex.
      example 'has leading spaces' do
        header = " Basic #{encoded}"

        expect { extract_encoded(header) }
        .to raise_error(BasicAuthError, BasicAuthError::DEFAULT_MESSAGE)
      end
    end
  end
end
