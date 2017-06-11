require 'reflection_utils'

module Encapsulate

  @@encapsulator_params = [[:keyreq, :callback], [:key, :params]]

  def self.run(callback:, with:, params:nil)
    ReflectionUtils.call(create(callback: callback, with: with), params)
  end

  def self.create(callback:, with:)
    lambdas = []
    lambdas[0] = callback

    with.each_with_index do |encapsulator, index|
      ReflectionUtils.assert_parameters(encapsulator, @@encapsulator_params)
      lambdas[index + 1] = lambda { |params = nil| encapsulator.call(callback: lambdas[index], params: params) }
    end

    lambdas.last
  end

end
