module Encapsulate

  class NestedMethodChain

    def self.run(callback:, with:, params:)
      run(callback, with, params)
    end

    def self.run(callback, with, params)
      create(callback, with, params).call(params)
    end

    def self.create(callback:, with:)
      create(callback, with)
    end

    def self.create(callback, with)
      lambdas = []
      lambdas[0] = callback

      runners.each_with_index do |runner, index|
        lambdas[index + 1] = lambda { |params| runner.call(callback: lambdas[index], params: params) }
      end

      lambdas.last
    end

  end

end
