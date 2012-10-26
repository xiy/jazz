require 'rgl/adjacency'
require 'rgl/dot'
require 'ruby_parser'
require 'jazz'

module Jazz
  # Summary
  #   Parses a Ruby source file, converting the source into a human-readable structure.
  #
  # Remarks
  #   Some of the code in this class is lifted graciously from the
  #   TomDoc project: github.com/defunkt/tomdoc.
  class Parser
    attr_accessor :source, :options, :graph
    attr_accessor :scopes
    attr_reader :ruby_parser

    # Constructor
    #
    # Params
    #   source - The Ruby source file to read from.
    #   options - A Hash of options to set on the parser.
    #
    def initialize(source, options = {})
      @options ||= {}
      @ruby_parser ||= RubyParser.new
      read_source(source)
      # @graph ||= RGL::DirectedAdjacencyGraph.new
    end

    # Summary
    #   Parses one or more source files, converting the AST representation of the source
    #   into a tokenised array, where the structure of the source is represented using objects.
    #
    #   Can also be used in block form where the tokens for mutiple input files are yielded
    #   one by one.
    #
    # Params
    #   *source - One or more Strings as paths to Ruby files.
    #
    # Returns a nested Array of tokens that include the token type, name, and
    # any comments associated with it OR nil if parsing failed or was ivalid.
    def parse(nested_scope = nil)
      raise InvalidSourceError, "No source set to read from." if @source.nil?
      @source.deep_each do |source_scope|
        case source_scope.sexp_type
        when :module, :class
          name = source_scope[1]
          p name
          scope = Scope.new(name, source_scope.comments, parse_methods)
        end
      end
    end

    # Summary
    #   Sets the source to read from.
    def source=(source)
      source_is_valid?
    end

    # Summary
    #   Uses RubyParser to convert a Ruby source file into an S-expression.
    #
    # Returns an S-expression that represents the Ruby source file.
    def to_sexp(source)
      @ruby_parser.parse(source)
    end

    # Summary
    #   Parses all class and instance methods from the source, with their arguments.
    #
    # Returns a Hash containing an Array of class methods and an Array of instance methods.
    def parse_methods
      abort unless source_is_valid?
      return nil if @source.find_nodes(:defn).nil? and @source.find_nodes(:defs).nil?

      instance_methods, class_methods = [], []

      # HMM: These two can probably be refactored later...

      @source.each_of_type(:defn) do |method|
        m = { :type => :instance_method, :name => method[1], :comments => method.comments,
              :args => get_method_args(method.find_node(:args)) }
        instance_methods << m
      end

      @source.each_of_type(:defs) do |method|
        m = { :type => :class_method, :name => method[2], :comments => method.comments,
              :args => get_method_args(method.find_node(:args)) }
        class_methods << m
      end

      return { :class_methods => class_methods, :instance_methods => instance_methods }
    end

    # Summary
    #   Extracts the arguments of a method from an S-expression tree, including any default values.
    #
    # Params
    #   args_node - The s(:args) node of the parsed method S-expression.
    #
    # Tested With
    #   RSpec: spec/jazz/parser_spec.rb
    def get_method_args(method_args)
      abort unless source_is_valid?

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
        method_args.each_of_type(:lasgn) do |node|
          default = node.sexp_body.flatten.reject { |e| [:block, :lasgn, :call, :lit].include? e }
          default_name, default_value = default[0], default[1]
          final_args[default_name] = default_value
        end
      end

      final_args
    end

    private

    def source_is_valid?
      # TODO: More verification needed.
      raise InvalidSourceError, "No source set to read from." if @source.nil?
      return true
    end

    def read_source(source)
      if source.respond_to? :each # is_a? Array
        source.each { |file| @source << to_sexp(File.read(file)) if file.respond_to? :read }
      elsif source.respond_to? :read # is_a? File
        @source = to_sexp(source.read)
      elsif source.respond_to? :to_s # is_a? String
        if source.end_with? ".rb" and File.exist?(source)
          @source = to_sexp(File.read(source))
        else
          @source = to_sexp(source)
        end
      end
    end
  end
end

class InvalidSourceError < StandardError; end
