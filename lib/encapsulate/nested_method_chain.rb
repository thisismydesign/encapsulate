module Encapsulate

  class NestedMethodChain

    def self.run(callback:, with:, params:nil)
      create(callback: callback, with: with).call(params)
    end

    def self.create(callback:, with:)
      lambdas = []
      lambdas[0] = callback

      with.each_with_index do |encapsulator, index|
        lambdas[index + 1] = lambda { |params| encapsulator.call(callback: lambdas[index], params: params) }
      end

      lambdas.last
    end

  end

end
