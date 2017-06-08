module Encapsulate

  class NestedMethodChain

    @@encapsulator_params = [[:keyreq, :callback], [:key, :params]]

    def self.run(callback:, with:, params:nil)
      call(create(callback: callback, with: with), params)
    end

    def self.create(callback:, with:)
      lambdas = []
      lambdas[0] = callback

      with.each_with_index do |encapsulator, index|
        assert_parameters(encapsulator, @@encapsulator_params)
        lambdas[index + 1] = lambda { |params = nil| encapsulator.call(callback: lambdas[index], params: params) }
      end

      lambdas.last
    end

    def self.call(callback, params = nil)
      params.nil? ? callback.call : callback.call(params)
    end

  private

    def self.has_parameters?(proc, parameters)
      parameters.each_with_index do |parameter, index|
        return false unless has_parameter(proc, index, parameter)
      end

      true
    end

    def self.assert_parameters(proc, parameters)
      parameters.each_with_index do |parameter, index|
        raise ArgumentError, "Argument #{parameter} not found for #{proc} at #{index} index." unless has_parameter(proc, index, parameter)
      end

      true
    end

    def self.has_parameter(proc, parameter_index, parameter)
      proc.parameters[parameter_index] == parameter
    end

  end

end
