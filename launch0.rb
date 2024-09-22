# Spawn the ipn.rb process and 

require 'net/http'
require 'timeout'
require 'simple_command_line_parser'
require 'colorize'
require 'pry'

# Parsing command line parameters.
parser = BlackStack::SimpleCommandLineParser.new(
  :description => 'This command will launch a Sinatra-based BlackStack webserver in background, returning an exit code 0 if the async process started successfully or 1 if the async process failed to start.', 
  :configuration => [{
    :name=>'path', 
    :mandatory=>false, 
    :description=>'Folder where the script `app.rb` is located.', 
    :type=>BlackStack::SimpleCommandLineParser::STRING,
    :default => ENV['RUBYLIB'] || '.',
  }, {
    :name=>'timeout', 
    :mandatory=>false, 
    :description=>'Timeout in seconds to wait for the web server to start.', 
    :type=>BlackStack::SimpleCommandLineParser::INT,
    :default => 5,
  }]
)

# Define the command to run the web server
cmd = "cd #{parser.value('path')} && ruby ./extensions/i2p/p/ipn.rb"

STDOUT.puts "Running command: #{cmd}"

# Create pipes for stdout and stderr
stdout_read, stdout_write = IO.pipe
stderr_read, stderr_write = IO.pipe

# Spawn the process with stdout and stderr redirected to the pipes
pid = Process.spawn(cmd, :out => '/dev/null', :err => '/dev/null', :pgroup => true, :in => :close)
#pid = Process.spawn(cmd, out: STDOUT, err: STDERR, pgroup: true, in: :close)

# Check if the process is alive after timeout
STDOUT.puts 'Give it a time to the process to start... '
success = false
sleep parser.value('timeout')

begin
  # Attempt to get the exit status without blocking
  result = Process.waitpid(pid, Process::WNOHANG)
  
  if result.nil?
    # The process is still running
    STDOUT.puts "Process #{pid} is still running after #{parser.value('timeout')} seconds.".green
    success = true
  else
    # The process has exited; get the exit status
    exit_status = $?.exitstatus
    STDERR.puts "Process #{pid} has exited with status #{exit_status}.".RED
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
