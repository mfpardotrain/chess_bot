# frozen_string_literal: true

require "net/http"
require "dotenv"
require_relative "lichess_api/lichess_challenge_handler"
require_relative "lichess_api/lichess_game_handler"
Dotenv.load

module LichessApi
  def self.get_account
    get_request("/account")
  end

  def self.get_challenge
    get_stream("/stream/event", LichessChallengeHandler.new)
  end

  def self.accept_challenge(challenge_id)
    post_request("/challenge/#{challenge_id}/accept")
  end

  def self.stream_game_state(game_id, lichess_game_handler)
    get_stream("/bot/game/stream/#{game_id}", lichess_game_handler)
  end

  def self.get_request(url_end)
    uri = URI(base_url + url_end)
    Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
      request = Net::HTTP::Get.new uri
      request["Authorization"] = auth_header

      http.request request
    end
  end

  def self.get_stream(url_end, handler)
    uri = URI(base_url + url_end)

    Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
      request = Net::HTTP::Get.new uri
      request["Authorization"] = auth_header

      http.request request do |response|
        response.read_body do |chunk|
          handler.parse_data(chunk)
        end
      end
    end
  end

  def self.post_request(url_end, body = nil)
    uri = URI(base_url + url_end)
    Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
      request = Net::HTTP::Post.new uri
      request["Authorization"] = auth_header
      request.body = body.to_json

      http.request request
    end
  end

  def self.form_data_post_request(url_end, body = nil)
    uri = URI(base_url + url_end)
    Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
      request = Net::HTTP::Post.new uri
      request["Authorization"] = auth_header
      request.set_form_data(body)

      http.request request
    end
  end

  def self.get_lichess_moves(url_end)
    uri = URI("https://explorer.lichess.ovh/lichess" + url_end)
    Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
      request = Net::HTTP::Get.new uri
      request["Authorization"] = auth_header

      http.request request
    end
  end

  def self.token
    ENV["lichessToken"]
  end

  def self.base_url
    "https://lichess.org/api"
  end

  def self.auth_header
    "Bearer #{token}"
  end
end
