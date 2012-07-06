require 'profiler/metric'

module Profiler
  module Helpers

    def profile_call(name, &block)
      metric = ::Profiler::Metric.new(name)
      parent_metric = ::Profiler::Helpers.current_profiler_context

      parent_metric << metric
      ::Profiler::Helpers.current_profiler_context = metric

      metric.profile {
        self.instance_eval(&block)
      }
    ensure
      ::Profiler::Helpers.current_profiler_context = parent_metric
    end

    class << self

      attr_reader   :root_profiler_context
      attr_accessor :current_profiler_context

      def start_profiling!
        @root_profiler_context = ::Profiler::Metric.new(:__root_context__)
        self.current_profiler_context = @root_profiler_context
      end

      def done_profiling!
        # Nothing special that we do here just yet.
      end

    end

    [:start_profiling!, :done_profiling!, :root_profiler_context].each do |sym|
      class_eval <<-end_eval, __FILE__, __LINE__
        def #{sym}(*args, &block)
          ::Profiler::Helpers.#{sym}(*args, &block)
        end
      end_eval
    end

  end
end
