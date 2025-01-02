# frozen_string_literal: true

require "json"
require_relative "lichess_game_handler"

module LichessApi
  class LichessChallengeHandler
    def parse_data(data)
      return unless data.is_a?(String) && data.length > 0

      # puts "data: #{data}"

      split = data.split("\n")
      split.each do |line|
        hash = JSON.parse(line)
        type = hash["type"]

        case type
        # TODO: make the different hashes into objects
        when "challenge"
          payload = hash["challenge"]
          puts "Challenged by: #{payload["destUser"]}, at: #{payload["url"]}"
          challenge_id = payload["id"]
          LichessApi.accept_challenge(challenge_id)
        when "gameStart"
          payload = hash["game"]
          puts "Game started against: #{payload["opponent"]}"
          game_id = payload["id"]
          color = payload["color"]
          LichessGameHandler.new(game_id, color).stream_game_state
        when "challengeCanceled"
          payload = hash["challenge"]
          puts "Challenged canceled by: #{payload["destUser"]}, at: #{payload["url"]}"
        when "gameFinish"
          payload = hash["game"]
          puts "Game complete against: #{payload["opponent"]}"
        else
          puts "unidentified type: #{type}"
        end
      end
    end
  end
end
