module Fixtures
  module Jenkins

    class Body; class << self
      def new(opts={})
        {
          build: {
            phase: opts[:phase] || "started",
            status: opts[:status],
            full_url: opts[:full_url],
            parameters: {
              ID: opts[:ID] || Time.now.to_i
            }
          }
        }.to_json
      end
    end; end

  end
end

