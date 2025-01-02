require "rubocop/rake_task"
require "standard/rake"
require_relative "lib/cli"

task default: %w[test]

RuboCop::RakeTask.new(:lint) do |task|
  task.patterns = ["lib/**/*.rb", "test/**/*.rb"]
  task.fail_on_error = false
  task.options = ["-a"]
end

task :run do
  Cli.run
end

task :test do
  ruby "test/cool_program_test.rb"
end
