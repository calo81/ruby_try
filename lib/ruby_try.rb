require "ruby_try/version"

module Kernel
  def Try(*args)
    if args
      
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
      while(value.is_a?(Try))
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
