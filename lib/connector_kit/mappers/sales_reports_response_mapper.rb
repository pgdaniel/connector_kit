require 'connector_kit/models/sales_reports'

module ConnectorKit
  # Mapper between a HTTParty response and a BuildDetails object
  class SalesReportsResponseMapper
    def map(data)
      SalesReports.new(data)
    end
  end
end
