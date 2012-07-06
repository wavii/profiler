module Profiler
  class Metric

    def initialize(name, &block)
      @name     = name
      @children = []

      self.profile(&block) if block
    end

    attr_reader :name
    attr_reader :children
    attr_reader :start
    attr_reader :end

    def start!
      @start = Time.now
    end

    def done!
      @end = Time.now
    end

    def profile(&block)
      self.start!

      block.call(self)
    ensure
      self.done!
    end

    def <<(child)
      self.children << child
    end

    def pretty_duration
      return "Didn't start!"  unless self.start
      return "Didn't finish!" unless self.end

      "%.3fms" % (self.duration * 1000.0)
    end

    def duration
      raise "#{self} didn't finish!" unless self.start && self.end

      self.end - self.start
    end

    def own_duration
      self.duration - self.children.map(&:duration).sum
    end

    def pretty_own_duration
      "%.3fms" % (self.duration * 1000.0)
    end

    def pretty(options=nil)
      options ||= {}

      depth = options[:depth] || 0

      line = "#{'  ' * depth}#{self.name}: #{self.pretty_duration} (#{self.pretty_own_duration})"
      return line unless options[:nested]

      lines = [line] + self.children.map { |child|
        child.pretty(options.merge(depth: depth + 1))
      }

      lines.join("\n")
    end

  end
end
