require "slim"
require "colorize"
require "jazz/version"
require "jazz/parser"
require "jazz/slim"
require "jazz/uberlogger"
require "jazz/scope"
require "jazz/method"
require "parallel"

include Jazz::UberLogger

# Ruby really should abort on unhandled exceptions by default...
Thread.abort_on_exception = true

class Object
  def deep_map(&block)
    block.call(self)
  end
end

class Array
  def deep_map(&block)
    map { |e| e.deep_map(&block) }
  end
end

class Sexp
  def parallel_deep_each(&block)
    self.parallel_each_sexp do |sexp|
      block[sexp]
      sexp.parallel_deep_each(&block)
    end
  end

  def parallel_each_sexp
    Parallel.each(self, :in_threads => Parallel.processor_count) do |sexp|
      new_sexp = ::Sexp.from_array(sexp)
      p sexp
      next unless Sexp === new_sexp
      yield new_sexp
    end
  end
end
