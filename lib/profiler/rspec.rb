require 'profiler/helpers'

module Profiler
  module RSpec
    include Profiler::Helpers

    def profiler_before_each
      start_profiling!
    end

    def profiler_after_each
      done_profiling!

      puts
      puts "#{self.class.description} #{self.example.description}:"
      root_profiler_context.children.each do |child|
        puts child.pretty(nested: true, depth: 1)
      end
      puts
    end

    # RSpec Hooks
    # -----------

    module ClassMethods

      def let(name, *args, &block)
        super(name, *args) {
          profile_call("let(:#{name})", &block)
        }
      end

    end

    class << self

      def included(parent)
        parent.extend self::ClassMethods

        parent.instance_eval do
          before(:each) { self.profiler_before_each }
          after(:each)  { self.profiler_after_each  }
        end
      end

    end

  end
end
