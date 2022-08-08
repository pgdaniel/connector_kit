require 'httparty'
require 'zlib'
require 'stringio'
require 'pry'


require 'connector_kit/exceptions'

module ConnectorKit
  # Simple HTTP client wrapper for HTTParty
  class HTTPClient
    include HTTParty

    def initialize(target_uri)
      self.class.base_uri(target_uri)
    end

    def get(url, response_mapper)
      response = self.class.get(url)

      if response.headers["content-type"] == "application/a-gzip"
        gz = Zlib::GzipReader.new(StringIO.new(response.body.to_s))    
        return uncompressed_string = gz.read
      end

      raise make_api_error(response) unless response.code == 200

      response_mapper.map(response.parsed_response['data'])
    end

    private

    def make_api_error(response)
      # For the time being, the first error received is enough
      error = response.parsed_response['errors'].first
      APIError.new(error['title'], error['detail'], error['status'])
    end
  end
end
