# frozen_string_literal: true

require "optparse"
require "cli/ui"
require_relative "lichess_api"
require_relative "lichess_api/lichess_openings"

module Cli
  def self.run
    options(ARGV)
    cli_menu

    LichessApi.get_challenge
    # LichessApi::LichessOpenings.new.major_openings.first(10).each {|el| puts el.name }
    # LichessApi::LichessOpenings.new.check_opening("alekine").each {|el| puts el.name}
  end

  def self.options(args)
    options = {}

    OptionParser.new do |opts|
      opts.on("-v", "--verbose", "Show extra information") do
        options[:verbose] = true
      end

      opts.on("-c", "--color", "Enable syntax highlighting") do
        options[:syntax_highlighting] = true
      end
    end.parse!(args)

    options
  end

  def self.select_options
    opts = {}
    CLI::UI::Prompt.ask("Would you like to start?") do |handler|
      handler.option("Yes") { opts[:start] = true }
      handler.option("No") { opts[:start] = false }
      handler.option("Exit") { exit }
    end
  end

  def self.cli_menu
    CLI::UI::StdoutRouter.enable
    [select_options]
  rescue Interrupt
    puts "Operation cancelled by user"
    exit 1
  rescue => e
    puts "Error with CLI menu opertaion: #{e.message}"
    exit 1
  ensure
    CLI::UI::StdoutRouter.disable
  end
end
