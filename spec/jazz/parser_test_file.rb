require 'jazz'

# Namespacing scope test
module Namespace
  module SomeModule
  end

  class SomeClass
    include SomeModule
  end
end

# Subclass scope test
class SubclassClass < String
end

# Singleton (eigenclass) scope test
class << self
end

# Method test
class ClassWithMethods
  def MethodWithoutParams
  end

  def MethodWithParams(param, another_param)
  end

  def MethodWithDefaultParams(param, another_param = {})
  end
end

