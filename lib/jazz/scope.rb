module Jazz
  # A Scope is a Module or Class object and may contain other Scopes.
  #
  # Lifted graciously from the TomDoc project: github.com/defunkt/tomdoc.
  class Scope
    include Enumerable

    attr_accessor :name, :comment, :instance_methods, :class_methods
    attr_accessor :scopes

    def initialize(name, comment = '', methods)
      @name = name
      @comment = comment
      @instance_methods = methods[:instance_methods]
      @class_methods = methods[:class_methods]
      @scopes = {}
    end

    def [](scope)
      @scopes[scope]
    end

    def keys
      @scopes.keys
    end

    def each(&block)
      @scopes.each(&block)
    end

    def to_s
      inspect
    end

    def inspect
      scopes = keys.join(', ')
      "<#{name} scopes:[#{scopes}] :#{class_methods}: ##{instance_methods}#"
    end
  end
end
