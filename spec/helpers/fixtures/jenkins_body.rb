module Fixtures
  module Jenkins

    class Body; class << self
      def new(opts={})
        {
          build: {
            phase: opts[:phase] || "started"
          }
        }.to_json
      end
    end; end

  end
end

