require 'net/http'
require 'timeout'
#require 'simple_command_line_parser'
require 'colorize'
#require 'pry'

# Example: 
# ```
# ruby launch0.rb "cd /home/leandro/code1/master && export RUBYLIB=/home/leandro/code1/master && ruby ./extensions/i2p/p/ipn.rb"
# ```

=begin
# Parsing command line parameters.
parser = BlackStack::SimpleCommandLineParser.new(
  :description => 'This command will launch a Sinatra-based BlackStack webserver in background, returning an exit code 0 if the async process started successfully or 1 if the async process failed to start.', 
  :configuration => [{
    :name=>'cmd', 
    :mandatory=>true, 
    :description=>'Command to run asynchroniously.', 
    :type=>BlackStack::SimpleCommandLineParser::STRING,
  }]
)
=end

# Assign values to variables
# TODO: Add support to simple_command_line_parser to detec a value between semicolos (") in order to pass a bash command as a parameter, and the timeout into another parameter
cmd = ARGV.last
timeout = 10

STDOUT.puts "Running command: #{cmd}"

# Spawn the process with stdout and stderr redirected to the pipes
pid = Process.spawn(cmd, out: '/dev/null', err: '/dev/null', pgroup: true, in: :close)

# Check if the process is alive after timeout
STDOUT.puts 'Give it a time to the process to start... '
success = false
sleep timeout

begin
  # Attempt to get the exit status without blocking
  result = Process.waitpid(pid, Process::WNOHANG)

  if result.nil?
    # The process is still running
    STDOUT.puts "Process #{pid} is still running after #{timeout} seconds.".green
    STDOUT.puts "Process spawning success.".green
    success = true
  else
    # The process has exited; get the exit status
    exit_status = $?.exitstatus
    STDERR.puts "Process #{pid} has exited with status #{exit_status}.".red
  end
rescue Errno::ECHILD
  # No child process exists
  STDERR.puts "Process #{pid} has already been reaped."
  # Optionally, retrieve exit status if available
  exit_status = $?.exitstatus
  STDERR.puts "Exit status was #{exit_status}." if exit_status
end

if success
  # Detach the child process to let it run independently
  Process.detach(pid)
  exit 0
else
  # Attempt to kill the child process
  begin
    Process.kill("TERM", pid)
    STDOUT.puts "Terminated the process.".yellow
  rescue Errno::ESRCH
    STDOUT.puts "Process already terminated.".yellow
  end
  exit 1
end
