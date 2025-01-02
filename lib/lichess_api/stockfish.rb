# frozen_string_literal: true

require "stockfish"

# Monkeypatch for moves rather than fen
module Stockfish
  class Engine
    def analyze(moves, options)
      execute "position startpos moves #{moves}"
      %w[depth movetime nodes].each do |command|
        if (x = options[command.to_sym])
          return execute "go #{command} #{x}"
        end
      end
    end
  end
end
