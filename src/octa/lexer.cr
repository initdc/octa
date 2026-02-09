require "compiler/crystal/syntax"
require "./ameba/tokenizer"

module Octa
  def self.lex(filename)
    lexer = Lexer.new(filename)

    Ameba::Tokenizer.new(lexer).run do |token|
      Lexer.print_token(token, lexer.token_end_location)
    end
  end

  class Lexer
    def self.new(filename)
      lexer = Crystal::Lexer.new(File.read(filename))
      lexer.filename = Path.new(Dir.current, filename).to_s
      lexer.doc_enabled = false
      lexer.comments_enabled = false
      lexer.count_whitespace = true
      lexer.wants_raw = true
      lexer.slash_is_regex = true
      lexer.wants_def_or_macro_name = false
      lexer
    end

    def self.print_token(token, end_local)
      puts(sprintf(
        "%-27s (%s,%s)-(%s,%s) %s",
        token.type,
        token.line_number, token.column_number - 1,
        end_local.line_number, end_local.column_number,
        case token.type
        when .delimiter_start?, .delimiter_end?
          token.raw.inspect
        when .ident?
          token.value.to_s.inspect
        when .newline?
          "\n".inspect
        when .eof?
          '\0'.inspect
        else
          token.value ? token.value.inspect : nil
        end
      ))
    end
  end
end
