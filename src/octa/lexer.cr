require "compiler/crystal/syntax"

module Octa
  def self.lex(filename)
    data, token_type_maxsize = Lexer.lex(filename)

    data.each do |d|
      Lexer.print_token(d[:token], d[:end_local], token_type_maxsize)
    end
  end

  class Lexer
    alias Token = NamedTuple(token: Crystal::Token, end_local: Crystal::Location)

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

    def self.lex(filename)
      lexer = Lexer.new(filename)
      data = Array(Token).new
      token_type_maxsize = 0

      loop do
        # 每次调用都会得到下一个 token
        token = lexer.next_token

        # 复制一份（Token 可被修改，所以需 dup）
        data << {token: token.dup, end_local: lexer.token_end_location.dup}
        token_type_maxsize = token.type.to_s.size > token_type_maxsize ? token.type.to_s.size : token_type_maxsize

        break if token.type.eof?
      end

      return data, token_type_maxsize
    end

    def self.print_token(token, end_local, token_type_maxsize)
      puts(sprintf(
        "%-#{token_type_maxsize}s (%s,%s)-(%s,%s) %s",
        token.type,
        token.line_number, token.column_number - 1,
        end_local.line_number, end_local.column_number,
        case token.type
        when .delimiter_start?, .delimiter_end?, .string_array_start?, .symbol_array_start?
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
