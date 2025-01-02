# frozen_string_literal: true

require "json"
require_relative "opening"

module LichessApi
  class LichessPotentialMove
    attr_accessor :white_win, :black_win, :draw, :total_for_move, :move_text, :opening

    def initialize(move, total_moves)
      @white_win = move["white"] || 0
      @black_win = move["black"] || 0
      @draw = move["draw"] || 0
      @total_for_move = white_win + black_win + draw
      @move_text = move["uci"]
      @total_moves = total_moves
      @opening = move.dig("opening") || {}
    end

    def white_win_percent
      white_win.fdiv(total_for_move)
    end

    def black_win_percent
      black_win.fdiv(total_for_move)
    end

    def draw_percent
      draw.fdiv(total_form_move)
    end

    def chosen_percent(round = 4)
      total_for_move.fdiv(@total_moves).round(round)
    end
  end
end
