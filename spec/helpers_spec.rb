require 'profiler/helpers'

describe Profiler::Helpers do

  let(:profilable_class) {
    Class.new.tap { |c| c.class_exec(described_class) { |mod|
      include mod

      def ohai
        profile_call(:ohai) { :ohai }
      end

      def do_things(obj, &block)
        obj.profile_call(:do_things, &block)
      end
    } }
  }

  let(:profilable) { profilable_class.new }
  let(:root) { profilable.root_profiler_context }

  def with_profiler(&block)
    profilable.start_profiling!

    profilable.instance_eval(&block)
  ensure
    profilable.done_profiling!
  end

  def name_tree(node=nil)
    node ||= root

    {node.name => node.children.map { |c| name_tree(c) }}
  end

  it "should expose a `profile` helper" do
    with_profiler do
      profile_call(:foo) { 2 + 2 }
    end

    root.children.map(&:name).should eq([:foo])
  end

  it "should evaluate blocks in the context of the current object" do
    with_profiler {
      profile_call(:foo) { self.ohai }
    }.should eq(:ohai)
  end

  it "should allow nested profiling" do
    with_profiler do
      profile_call(:foo) do
        profile_call(:bar) do
          self.ohai
        end
      end
    end

    name_tree.should eq(
      __root_context__: [
        {foo: [
          {bar: [
            {ohai: []}
          ]}
        ]}
      ]
    )
  end

  it "should allow profiling across objects and classes" do
    other_inst = profilable_class.new
    other_mod  = Module.new.tap do |mod|
      mod.module_exec(described_class) { |m| extend m }
    end

    with_profiler do
      profile_call(:stuff) { 2 + 2 }

      do_things(other_inst) {
        other_mod.profile_call(:from_mod) { 2 + 2 }
      }
    end

    name_tree.should eq(
      __root_context__: [
        {stuff: []},
        {do_things: [
          {from_mod: []}
        ]}
      ]
    )
  end

  it "should not freak out if you profile before starting" do
    Profiler::Helpers.current_profiler_context = nil

    profilable.instance_eval {
      profile_call(:hi) { 2 + 2 }
    }
  end

end
