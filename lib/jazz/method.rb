module Jazz
  class Method
    attr_accessor :name, :comment, :args

    def initialize(name, comment = '', args = [])
      @name = name
      @comment = comment
      @args = args
    end

    alias_method :to_s, :name

    def inspect
      "#{name}(#{args.join(', ')})"
    end
  end
end
