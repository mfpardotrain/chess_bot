# frozen_string_literal: true

require "json"
require_relative "lichess_potential_move"

module LichessApi
  class LichessPlayerData
    attr_accessor :total_white_wins, :total_black_wins, :total_draws, :total_games, :database_moves

    def initialize(lichess_moves_response)
      @total_white_wins = lichess_moves_response["white"] || 0
      @total_black_wins = lichess_moves_response["black"] || 0
      @total_draws = lichess_moves_response["draw"] || 0
      @total_games = total_black_wins + total_white_wins + total_draws
      @database_moves = lichess_moves_response["moves"]
    end

    def potential_next_moves
      database_moves.map do |move|
        LichessPotentialMove.new(move, total_games)
      end
    end

    def current_white_win_percent
      total_white_wins.fdiv(total_games)
    end

    def current_black_win_percent
      total_black_wins.fdiv(total_games)
    end

    def current_draw_percent
      total_draws.fdiv(total_games)
    end
  end
end
