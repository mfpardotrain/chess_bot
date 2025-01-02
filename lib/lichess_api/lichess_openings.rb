# frozen_string_literal: true

require "csv"
require "levenshtein"
require_relative "opening"

module LichessApi
  class LichessOpenings
    attr_accessor :openings

    def initialize
      @openings = []
      CSV.foreach("openings.csv") do |opening|
        @openings << Opening.new(opening)
      end
    end

    def check_opening(name)
      min_dist = 1.0 / 0
      potential_openings = []
      cur_names = []

      @openings.each_with_index do |opening, i|
        dist = Levenshtein.normalized_distance name, opening.name
        if dist < min_dist
          min_dist = dist
          potential_openings = [opening]
          cur_names = [opening.name]
        elsif dist == min_dist && !cur_names.include?(opening.name)
          potential_openings << opening
          cur_names << opening.name
        end
      end
      potential_openings
    end

    def get_variations(name)
      variations = []
      @opening_names.each_with_index do |opening_name, i|
        variations << @openings[i] if opening_name.include?(name)
      end
      variations
    end

    def major_openings
      out = @openings.map do |opening|
        next if opening.name.include?(":")
        opening
      end
      out.compact
    end
  end
end
