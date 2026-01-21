require "compiler/crystal/syntax"

module Octa
  def self.parse(filename)
    parser = Crystal::Parser.new(File.read(filename))
    parser.filename = filename
    parser.doc_enabled = false
    parser.comments_enabled = false
    parser.count_whitespace = true
    parser.wants_raw = true
    parser.slash_is_regex = true
    parser.wants_def_or_macro_name = false

    nodes = parser.parse.as(Crystal::Expressions)
    nodes.expressions.each do |node|
      puts "------ #{node.class}"
      p node
    end
  end
end
