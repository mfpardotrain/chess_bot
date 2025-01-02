# frozen_string_literal: true

require "json"

module LichessApi
  class LichessDecisionEngine
    attr_accessor :potential_next_moves

    def initialize(potential_next_moves, chosen_opening)
      @potential_next_moves = potential_next_moves
      @chosen_opening = chosen_opening
    end

    def decide
      return potential_next_moves[0] if potential_next_moves.length == 1

      opening_moves = @chosen_opening.moves.split(" ")
      puts "opening: #{opening_moves}"
      potential_next_moves.max_by do |move|
        modifier = if opening_moves.include?(move.move_text)
          1.0
        else
          0.2
        end
        rand**1.fdiv(move.chosen_percent * modifier)
      end
    end
  end
end
