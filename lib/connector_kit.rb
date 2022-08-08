require 'connector_kit/httpclient.rb'
require 'connector_kit/token_generator'
require 'connector_kit/version'
require 'connector_kit/mappers/app_list_response_mapper'
require 'connector_kit/mappers/user_list_response_mapper'
require 'connector_kit/mappers/build_list_response_mapper'
require 'connector_kit/mappers/build_details_response_mapper'
require 'connector_kit/mappers/sales_reports_response_mapper'

module ConnectorKit
  # Class used for communicating with the App Store Connect API
  class Client

    attr_reader :issuer_id, :key_id, :private_key_file_path, :token_generator, :vendor_number

    def initialize(issuer_id, key_id, private_key_file_path, vendor_number=nil)
        @issuer_id = issuer_id
        @key_id = key_id
        @private_key_file_path = private_key_file_path
        @vendor_number = vendor_number

      @token_generator = TokenGenerator.new(
        issuer_id,
        key_id,
        private_key_file_path
      )

      @httpclient = HTTPClient.new('https://api.appstoreconnect.apple.com/v1')

      @httpclient.class.headers(
        'Authorization' => "Bearer #{token_generator.generate_token}"
      )
    end

    def apps
      @httpclient.get '/apps', AppListResponseMapper.new
    end

    def users
      @httpclient.get '/users', UserListResponseMapper.new
    end

    def app_builds(app)
      @httpclient.get "/apps/#{app.id}/builds", BuildListResponseMapper.new
    end

    def sales_reports
      @httpclient.class.headers(
        'Authorization' => "Bearer #{token_generator.generate_token}",
        'Accept' => 'application/a-gzip',
        'Accept-Encoding' => 'gzip,deflate,identity'
      )
      @httpclient.get("/salesReports?filter[reportType]=SALES&filter[reportSubType]=SUMMARY&filter[frequency]=DAILY&filter[vendorNumber]=#{vendor_number}", SalesReportsResponseMapper.new)
    end

    def build_beta_details(build)
      @httpclient.get(
        "/buildBetaDetails/#{build.id}",
        BuildDetailsResponseMapper.new
      )
    end
  end
end
