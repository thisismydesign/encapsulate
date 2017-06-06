module Encapsulate

  class AbstractEncapsulator

    def self.run(callback:, params: nil)
      call(callback, params)
    end

    def self.call(callback, params = nil)
      params.nil? ? callback.call : callback.call(params)
    end

  end

end
