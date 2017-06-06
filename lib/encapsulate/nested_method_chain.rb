module Encapsulate

  class NestedMethodChain

    def self.run(callback:, with:, params:nil)
      call(create(callback: callback, with: with), params)
    end

    def self.create(callback:, with:)
      lambdas = []
      lambdas[0] = callback

      with.each_with_index do |encapsulator, index|
        lambdas[index + 1] = lambda { |params = nil| encapsulator.call(callback: lambdas[index], params: params) }
      end

      lambdas.last
    end

    def self.call(callback, params = nil)
      params.nil? ? callback.call : callback.call(params)
    end

  end

end
