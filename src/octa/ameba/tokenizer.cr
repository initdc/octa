# The MIT License (MIT)

# Copyright (c) 2018-2020 Vitalii Elenhaupt

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

require "compiler/crystal/syntax/*"

module Ameba
  # Represents Crystal syntax tokenizer based on `Crystal::Lexer`.
  #
  # ```
  # source = Ameba::Source.new code, path
  # tokenizer = Ameba::Tokenizer.new(source)
  # tokenizer.run do |token|
  #   puts token
  # end
  # ```
  class Tokenizer
    # Instantiates Tokenizer using a `source`.
    #
    # ```
    # source = Ameba::Source.new code, path
    # Ameba::Tokenizer.new(source)
    # ```
    def initialize(source)
      @lexer = Crystal::Lexer.new source.code
      @lexer.count_whitespace = true
      @lexer.comments_enabled = true
      @lexer.wants_raw = true
      @lexer.filename = source.path
    end

    # Instantiates Tokenizer using a `lexer`.
    #
    # ```
    # lexer = Crystal::Lexer.new(code)
    # Ameba::Tokenizer.new(lexer)
    # ```
    def initialize(@lexer : Crystal::Lexer)
    end

    # Runs the tokenizer and yields each token as a block argument.
    #
    # ```
    # Ameba::Tokenizer.new(source).run do |token|
    #   puts token
    # end
    # ```
    def run(&block : Crystal::Token -> _)
      run_normal_state @lexer, &block
      true
    rescue e : Crystal::SyntaxException
      # puts e
      false
    end

    private def run_normal_state(lexer, break_on_rcurly = false, &block : Crystal::Token -> _)
      loop do
        token = @lexer.next_token
        block.call token

        case token.type
        when .delimiter_start?
          run_delimiter_state lexer, token, &block
        when .string_array_start?, .symbol_array_start?
          run_array_state lexer, token, &block
        when .eof?
          break
        when .op_rcurly?
          break if break_on_rcurly
        end
      end
    end

    private def run_delimiter_state(lexer, token, &block : Crystal::Token -> _)
      loop do
        token = @lexer.next_string_token(token.delimiter_state)
        block.call token

        case token.type
        when .interpolation_start?
          run_normal_state lexer, break_on_rcurly: true, &block
        when .delimiter_end?, .eof?
          break
        end
      end
    end

    private def run_array_state(lexer, token, &block : Crystal::Token -> _)
      loop do
        lexer.next_string_array_token
        block.call token

        case token.type
        when .string_array_end?, .eof?
          break
        end
      end
    end
  end
end
