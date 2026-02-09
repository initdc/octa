require "./octa/lexer"
require "./octa/parser"
require "./octa/transpiler"

module Octa
  VERSION = "0.1.0"

  class CLI
    def self.run
      case ARGV[0]?
      when "lex"
        ARGV[1]? ? Octa.lex(ARGV[1]) : puts "Please input filename"
      when "parse"
        ARGV[1]? ? Octa.parse(ARGV[1]) : puts "Please input filename"
      when "cr-rb"
        ARGV[1]? ? Octa.cr_rb(ARGV[1]) : puts "Please input filename"
      else
        puts <<-EOF
        Usage: octa <command> [args]
        Commands:
          lex <filename>                  Lex the given file
          parse <filename>                Parse the given file
          cr-rb <filename>                Convert Crystal to Ruby
        EOF
      end
    end
  end
end

Octa::CLI.run
