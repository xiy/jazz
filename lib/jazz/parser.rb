require 'rgl/adjacency'
require 'rgl/dot'
require 'ruby_parser'

module Jazz
  # Parses a Ruby source file, converting the source into a human-readable structure.
  #
  # Remarks
  #   Some of the code in this class is lifted graciously from the
  #   TomDoc project: github.com/defunkt/tomdoc.
  class Parser
    attr_accessor :source, :options, :graph
    attr_accessor :tokenised_source
    attr_reader :ruby_parser

    def initialize(options = Hash.new)
      @options ||= {}
      @ruby_parser ||= RubyParser.new
      @graph ||= RGL::DirectedAdjacencyGraph.new
    end

    # Parses one or more source files, converting the AST representation of the source
    # into a tokenised array, where the structure of the source is represented using objects.
    #
    # Can also be used in block form where the tokens for mutiple input files are yielded
    # one by one.
    #
    # *source - One or more Strings as paths to Ruby files.
    #
    # Returns a nested Array of tokens that include the token type, name, and
    # any comments associated with it OR nil if parsing failed or was ivalid.
    def parse(*source)
      source.each do |file|
        sexp = to_sexp(file)
        methods = parse_methods
      end
    end

    def source=(source)
      if source.respond_to? :each # is_a? Array
        source.each do |file|
          @source << to_sexp(File.read(file))
        end
      elsif source.respond_to? :read # is_a? File
        @source = to_sexp(source.read)
      elsif source.respond_to? :to_s # is_a? String
        @source = to_sexp(File.read(source.to_s))
      end
    end

    # Uses RubyParser to convert a Ruby source file into an S-expression.
    #
    # Returns an S-expression that represents the Ruby source file.
    def to_sexp(source)
      @ruby_parser.parse(source)
    end

    def parse_methods
      unless @source.nil?
        instance_methods, class_methods = [], []

        @source.each_of_type(:defn) do |method|
          #p method
          m = { :type => :instance_method, :name => method[1], :comments => method.comments,
            :args => get_method_args(method.find_node(:args)) }
          yield m if block_given?
          instance_methods << m
        end

        @source.each_of_type(:defs) do |method|
          # p method
          m = { :type => :class_method, :name => method[2], :comments => method.comments,
            :args => get_method_args(method.find_node(:args)) }
          yield m if block_given?
          class_methods << m
        end

         class_methods + instance_methods
      end
    end

    # > Summary
    # Extracts the arguments of a method from an S-expression tree, including any default values.
    #
    # > Params
    # args_node - The s(:args) node of the parsed method S-expression.
    #
    # > Tested With
    # RSpec: spec/jazz/parser_spec.rb [describe "#get_method_args"]
    def get_method_args(method_args)
      # extract all the args from the :args node
      args = method_args.sexp_body.select { |arg| arg.is_a? Symbol } if method_args.is_a? ::Sexp

      # if the condition above is false, we reach this line and return nil
      # whether we were passed a valid parameter or not. NINJA.
      return nil if args.nil?

      # fill the return hash with all the args, with nil for their default values
      final_args = {}
      args.each { |e| final_args[e] = :nil }

      # we also need to check if any args actually have defaults, and if so, retrieve them
      unless method_args.find_node(:block).nil?
        defaults = method_args.each_of_type(:lasgn) do |node|
          default = node.sexp_body.flatten.reject { |e| [:block, :lasgn, :call, :lit].include? e }
          default_name, default_value = default[0], default[1]
          final_args[default_name] = default_value if args.include? default_name
        end
      end

      final_args
    end
  end

  # > Summary
  # An extremely sexy, polymorphic way of recursively mapping a multi-dimensional Array in Ruby.
  #
  # > Params
  # &block - a block.
  #
  # > See
  # http://stackoverflow.com/questions/6078138/find-and-replace-in-a-ruby-multi-dimensional-array
  #
  # > Tests
  # Spec: spec/jazz/parser_spec.rb
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
end
