# frozen_string_literal: true

require "json"
require_relative "lichess_player_data"
require_relative "lichess_decision_engine"
require_relative "stockfish"
require_relative "lichess_chat_handler"
require_relative "lichess_openings"

module LichessApi
  class LichessGameHandler
    attr_accessor :game_id, :moves, :color, :in_database, :in_opening

    def initialize(game_id, color)
      puts "initialize: #{color}"
      @game_id = game_id
      @color = color
      @in_database ||= true
      @in_opening ||= true
      @chat_handler = LichessChatHandler.new
      @chosen_opening = LichessOpenings.new.openings[993]
      puts "opening name: #{@chosen_opening.name}"
    end

    def stream_game_state
      LichessApi.stream_game_state(game_id, self)
    end

    def parse_data(data)
      return unless data.is_a?(String) && data.length.positive?

      split = data.split("\n")
      split.each do |line|
        hash = JSON.parse(line)
        type = hash["type"]

        case type
        # TODO: make the different hashes into objects
        when "gameFull"
          @moves = hash["state"]["moves"].split(" ")
          puts "full: is_turn: #{moves.length.odd? ^ (color == "white")}"
          make_move(make_decision) if moves.length.odd? ^ (color == "white")
        when "gameState"
          @moves = hash["moves"].split(" ") || []
          puts "state: is_turn: #{moves.length.odd? ^ (color == "white")}"
          make_move(make_decision) if moves.length.odd? ^ (color == "white")
        when "chatLine"
        #   @chat_handler.handle_chat(hash["text"])
        when "opponentGone"
          puts "gone"
        else
          puts "unidentified type: #{type}"
        end
      end
    end

    def make_move(move)
      LichessApi.post_request("/bot/game/#{game_id}/move/#{move.move_text}")
    end

    def make_decision
      # TODO: move this to the player data class
      comma_moves = moves.join(",")
      res = LichessApi.get_lichess_moves("?variant=standard&speeds=blitz,rapid,classical&ratings=1600,2500&moves=40&play=#{comma_moves}")
      body = JSON.parse(res.body)

      lichess_data = LichessPlayerData.new(body)

      if lichess_data.potential_next_moves.empty?
        puts "in db: #{@in_database}"
        # Check if we need to send a message about not having more database moves
        if @in_database
          body = {room: "player", text: "No more database moves, switching to stockfish"}
          LichessApi.form_data_post_request("/bot/game/#{game_id}/chat", body)
          @in_database = false
        end

        # Find a stockfish move
        space = moves.join(" ")
        stock = Stockfish.analyze(space, {depth: 12})
        move = {uci: stock[:bestmove]}.transform_keys(&:to_s)

        total_games = 0
        potential_next_moves = [LichessPotentialMove.new(move, total_games)]
      else
        lichess_data.total_games
        potential_next_moves = lichess_data.potential_next_moves
      end

      LichessDecisionEngine.new(potential_next_moves, @chosen_opening).decide
    end
  end
end
