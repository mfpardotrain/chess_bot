# frozen_string_literal: true

module LichessApi
  class Opening
    attr_accessor :code, :name, :moves, :root

    def initialize(opening)
      @moves = opening[4]
      @name = opening[2]
      @code = opening[1]
      @root = opening[2].split(":")[0]
    end
  end
end
