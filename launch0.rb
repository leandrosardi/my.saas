# Spawn the ipn.rb process and 

require 'net/http'
require 'timeout'
require 'simple_command_line_parser'
require 'colorize'

# Define the command to run the web server
timeout = 10
cmd = "cd /home/blackstack/code1/master && ruby ./extensions/i2p/p/ipn.rb"

STDOUT.puts "Running command: #{cmd}"

# Spawn the process with stdout and stderr redirected to the pipes
pid = Process.spawn(cmd, :out => '/dev/null', :err => '/dev/null', :pgroup => true, :in => :close)
#pid = Process.spawn(cmd, out: STDOUT, err: STDERR, pgroup: true, in: :close)

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
