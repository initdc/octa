require "compiler/crystal/syntax"

module Octa
  def self.parse(filename)
    Parser.parse_nodes(filename).each do |node|
      puts "------ #{node.class}"
      p node
    end
  end

  class Parser
    def self.new(filename)
      parser = Crystal::Parser.new(File.read(filename))
      parser.filename = Path.new(Dir.current, filename).to_s
      parser.doc_enabled = false
      parser.comments_enabled = false
      parser.count_whitespace = true
      parser.wants_raw = true
      parser.slash_is_regex = true
      parser.wants_def_or_macro_name = false
      parser
    end

    def self.parse_nodes(filename)
      Parser.new(filename).parse.as(Crystal::Expressions).expressions
    end
  end
end
