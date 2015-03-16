require "ruby_try/version"

module Kernel
  def Try(*args)
    raise "Only params OR exclusive block are permited, not both" if args.any? && block_given?
    args.each do |method_name|
      self.send(:alias_method, :"original_#{method_name}", method_name)
      self.send(:define_method, method_name) do |*args|
        begin
          RubyTry::Success.new(self.send("original_#{method_name}", *args))
        rescue => e
          RubyTry::Failure.new(e)
        end
      end
    end
    return unless block_given?
    value = yield
    RubyTry::Success.new(value)
  rescue => e
    RubyTry::Failure.new(e)
  end
end

module RubyTry

  class Try

    def initialize(value)
      @value = value
    end

    def failure?
      !success?
    end

    def value
      value = @value
      while (value.is_a?(Try))
        value = value.value
      end
      value
    end
  end

  class Success < Try

    def map
      Success.new(Try { yield(value) })
    end

    def success?
      true
    end

    def value_or(_)
      value
    end
  end

  class Failure < Try

    alias_method :error, :value

    def initialize(value)
      @value = value
    end

    def success?
      false
    end

    def map
      Failure.new(value)
    end

    def value_or(value)
      value
    end
  end

end
