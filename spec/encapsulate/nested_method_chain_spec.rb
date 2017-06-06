require "spec_helper"

RSpec.describe Encapsulate::NestedMethodChain do

  context "Without any chain elements" do
    it "Will simply call callback" do
      return_value = 'hi'
      lam = lambda { return_value }
      expect(Encapsulate::NestedMethodChain.run(callback: lam, with: [])).to eq(return_value)
    end

    it "Will simply call callback with given parameters" do
      return_value = 'hi'
      lam = lambda { |x| return x }
      expect(Encapsulate::NestedMethodChain.run(callback: lam, with: [], params: return_value)).to eq(return_value)
    end
  end

end
