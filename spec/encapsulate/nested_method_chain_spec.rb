require "spec_helper"

RSpec.describe Encapsulate::NestedMethodChain do

  describe "#create" do
    it "Will create a lambda expression" do
      returned_value = Encapsulate::NestedMethodChain.create(callback: lambda {}, with: [])
      expect(returned_value.lambda?).to be true
    end
  end

  describe "#run" do

    it "Can take lambda as `callback` parameter" do
      callback = lambda { }
      expect(callback).to receive(:call)
      Encapsulate::NestedMethodChain.run(callback: callback, with: [])
    end

    it "Can take Proc as `callback` parameter" do
      callback = Proc.new {}
      expect(callback).to receive(:call)
      Encapsulate::NestedMethodChain.run(callback: callback, with: [])
    end

    context "Without any encapsulation" do
      it "Will call and return the result of callback" do
        return_value = 'hi'
        callback = lambda { return_value }
        expect(Encapsulate::NestedMethodChain.run(callback: callback, with: [])).to eq(return_value)
      end

      it "Will call callback with given parameters" do
        return_value = 'hi'
        callback = lambda { |x| return x }
        expect(Encapsulate::NestedMethodChain.run(callback: callback, with: [], params: return_value)).to eq(return_value)
      end
    end

    context "With one encapsulating function" do
      it "Will call the encapsulator and pass the callback function as first parameter" do
        callback = lambda {}
        encapsulator = lambda { |callback:, params: nil| return callback }
        expect(Encapsulate::NestedMethodChain.run(callback: callback, with: [encapsulator])).to eq(callback)
      end

      it "Will call the encapsulator and pass params as second parameter" do
        params = {}
        callback = lambda {}
        encapsulator = lambda { |callback:, params: nil| return params }
        expect(Encapsulate::NestedMethodChain.run(callback: callback, with: [encapsulator], params: params)).to eq(params)
      end

      it "Will call the encapsulator and pass `nil` as default second parameter" do
        callback = lambda {}
        encapsulator = lambda { |callback:, params: nil| return params }
        expect(Encapsulate::NestedMethodChain.run(callback: callback, with: [encapsulator])).to eq(nil)
      end
    end


    context "With several encapsulating function" do
      it "Will nest encapsulators" do
        callback = lambda {}
        faulty_encapsulator = lambda { |callback:, params: nil| throw 'error occured' }
        exception_handling_encapsulator = 
        lambda do |callback:, params: nil|
          begin
            callback.call
          rescue Exception => e
            'exception occured'
          end
        end

        expect{ Encapsulate::NestedMethodChain.run(callback: callback, with: [faulty_encapsulator, exception_handling_encapsulator]) }.to_not raise_error
      end
    end

    context "With several encapsulating function" do
      it "Will nest encapsulators in order" do
        callback = lambda {}
        param = {modify_this: 'default'}
        encapsulator1 = lambda { |callback:, params: nil| params[:modify_this] = 'encapsulator1'; return params }
        encapsulator2 = lambda { |callback:, params: nil| params[:modify_this] = 'encapsulator2'; return params }

        returned_value = Encapsulate::NestedMethodChain.run(callback: callback, with: [encapsulator1, encapsulator2], params: param)
        expect(returned_value[:modify_this]).to eq('encapsulator2')
      end
    end

  end

end
