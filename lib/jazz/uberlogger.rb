require "colorize"

module Jazz
  module UberLogger
    def inspect_var(name, var)
      raise ArgumentError, "Object name should be passed as a symbol." if !name.is_a? Symbol
      object_name = name
      object_value = var
      after_stars = 100 - (object_name.length + 4)
      puts
      puts ("_" * 2 + "[#{object_name}]" + "_" * after_stars).light_black
      puts "\n\t=> #{object_value}\n".yellow
      puts "_" * 100
      puts
    end
  end
end
