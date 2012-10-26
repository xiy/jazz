require 'slim'

module Jazz
  module Slim
    def process(template)
      template_file = File.read(template) if File.exists?(template)
      output = Slim::Engine.new(:file => template,
                                :pretty => true,
                                :sections => false,
                                :disable_capture => false,
                                :generator => Temple::Generators::ArrayBuffer).call(template_file)
      return output
    end
  end
end
