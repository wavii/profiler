require 'profiler/metric'

describe Profiler::Metric do

  let(:metric) { described_class.new(:some_metric) }

  let(:finished_metric) {
    metric.tap { |m| m.start!; m.done! }
  }

  it "should expose the metric name" do
    metric.name.should eq(:some_metric)
  end

  it "should not have a duration until it has completed" do
    expect { metric.duration }.to raise_error

    metric.start!
    expect { metric.duration }.to raise_error

    metric.done!

    expect { metric.duration }.to_not raise_error
  end

  it "should provide a helper to time a block" do
    result = metric.profile { :ohai }

    result.should eq(:ohai)
    metric.duration.should >= 0.0
  end

  it "should provide a helper to time a block from the constructor" do
    new_metric = described_class.new(:another_metric) do |m|
      m.should be_a(described_class)
    end

    new_metric.duration.should >= 0.0
  end

  it "should provide a helper to append a child via <<" do
    child = described_class.new(:child_metric)
    metric << child

    metric.children.should eq([child])
  end

  it "should provide a pretty duration" do
    finished_metric.pretty_duration.should match(/[\d\.]+ms/)
  end

  it "should give a textual error when calling pretty until it has completed" do
    metric.pretty_duration.should eq("Didn't start!")

    metric.start!
    metric.pretty_duration.should eq("Didn't finish!")
  end

  it "should provide a pretty description" do
    finished_metric.pretty.should match(/^some_metric: [\d\.]+ms$/)
  end

  describe "with a complex tree" do
    let(:metric) {
      described_class.new(:root_metric) do |m|
        m << described_class.new(:child1).tap { |m| m.start!; m.done! }
        m << described_class.new(:child2).tap { |m| m.start!; m.done! }
        m << described_class.new(:child3) do |c3|
          c3 << described_class.new(:grandchild1).tap { |m| m.start!; m.done! }
        end
        m << described_class.new(:child4).tap { |m| m.start!; m.done! }
      end
    }

    it "should not display nested results by default" do
      metric.pretty.should match(/^root_metric: [\d\.]+ms$/)
    end

    it "should display pretty nested results when asked for" do
      lines = metric.pretty(nested: true).split("\n")

      lines[0].should match(/^root_metric: [\d\.]+ms$/)
      lines[1].should match(/^  child1: [\d\.]+ms$/)
      lines[2].should match(/^  child2: [\d\.]+ms$/)
      lines[3].should match(/^  child3: [\d\.]+ms$/)
      lines[4].should match(/^    grandchild1: [\d\.]+ms$/)
      lines[5].should match(/^  child4: [\d\.]+ms$/)
    end
  end

end
