require 'profiler/rspec'

describe Profiler::RSpec do
  include described_class

  before(:all) do
    # trap stdout?
  end

  describe 'for a spec using let' do

    let(:ohai) { :ohai }
    let(:obai) { :obai }
    let(:nested) { ohai; obai }
    let(:deep) {
      nested; nested
    }

    it 'should pick up lets' do
      ohai.should eq(:ohai)
    end

    it 'should properly nest lets' do
      deep.should eq(:obai)
    end

  end

end
