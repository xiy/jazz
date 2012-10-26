require "spec_helper"

describe Jazz::Parser do
  subject do
    Jazz::Parser.new("spec/jazz/parser_test_file.rb")
  end

  describe "#parse" do
    it "should parse all scopes in the source file" do
      subject.parse
    end
  end

  describe "#parse_methods" do
    it "should parse all methods in a source file" do
      p subject.parse_methods
    end
  end

  describe "#get_method_args" do
    it "should return args with defaults if a method has them" do

      expected = { arg: :nil, arg_with_default: :hash, another_arg: :nil }

      test_args = s(:args, :arg, :arg_with_default, :another_arg,
        s(:block,
          s(:lasgn, :arg_with_default, s(:hash))
        )
      )
     subject.get_method_args(test_args).should == expected
    end
  end
end
