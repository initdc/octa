require "compiler/crystal/syntax"

module Octa
  def self.cr_rb(source)
    Transpiler.new(source).cr_rb
  end

  class Transpiler
    def initialize(@source : String)
    end

    def cr_rb
    end
  end
end
