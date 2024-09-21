#!/usr/bin/env ruby
require 'net/http'
require 'timeout'
require 'simple_command_line_parser'
require 'colorize'

# --------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Parsing command line parameters.
# 
parser = BlackStack::SimpleCommandLineParser.new(
  :description => 'This command will launch a Sinatra-based BlackStack webserver in background, returning an exit code 0 if the async process started successfully or 1 if the async process failed to start.', 
  :configuration => [{
    :name=>'path', 
    :mandatory=>false, 
    :description=>'Folder where the script `app.rb` is located.', 
    :type=>BlackStack::SimpleCommandLineParser::STRING,
    :default => ENV['RUBYLIB'] || '.',  # Correctly expand the RUBYLIB environment variable
  }, {
    :name=>'timeout', 
    :mandatory=>false, 
    :description=>'Timeout in seconds to wait for the web server to start.', 
    :type=>BlackStack::SimpleCommandLineParser::INT,
    :default => 30,
  }, {
    :name=>'port', 
    :mandatory=>false, 
    :description=>'Listening port.', 
    :type=>BlackStack::SimpleCommandLineParser::INT,
    :default => 3000,
  }, {
    :name=>'config', 
    :mandatory=>false, 
    :description=>'Name of the configuration file.', 
    :type=>BlackStack::SimpleCommandLineParser::STRING,
    :default => 'config',
  }]
)

# Function to check if the web server is running by making an HTTP request
def server_running?(port)
  uri = URI("http://localhost:#{port}")
  begin
    # Try to open the connection with a short timeout
    Timeout.timeout(1) do
      response = Net::HTTP.get_response(uri)
      return response.is_a?(Net::HTTPSuccess) || response.is_a?(Net::HTTPRedirection)
    end
  rescue Errno::ECONNREFUSED, Timeout::Error
    return false
  end
end

# Define the command to run the web server
cmd = "ruby #{parser.value('path')}/app.rb port=#{parser.value('port')} config=#{parser.value('config')}"

STDOUT.puts "Running command: #{cmd}"

# Create pipes for stdout and stderr
stdout_read, stdout_write = IO.pipe
stderr_read, stderr_write = IO.pipe

# Spawn the process with stdout and stderr redirected to the pipes
pid = Process.spawn(cmd, out: stdout_write, err: stderr_write)

# Close the write ends in the main process as they are now connected to the child process
stdout_write.close
stderr_write.close

# Start threads to read from the pipes and forward to main stdout and stderr
stdout_thread = Thread.new do
  begin
    stdout_read.each_line do |line|
      STDOUT.puts "app.rb STDOUT: #{line}"
    end
  rescue IOError
    # Handle IO errors if necessary
  end
end

stderr_thread = Thread.new do
  begin
    stderr_read.each_line do |line|
      STDERR.puts "app.rb STDERR: #{line.red}"
    end
  rescue IOError
    # Handle IO errors if necessary
  end
end

# Function to check if a process is still running
def process_running?(pid)
  begin
    Process.getpgid(pid)
    true
  rescue Errno::ESRCH
    false
  end
end

# Check if the server is responding
success = false
start_time = Time.now
timeout = parser.value('timeout')
port = parser.value('port')

#STDOUT.puts "Waiting for web server to start..."
#sleep(10)

STDOUT.puts "Waiting for web server to start..."

loop do
  # Check if the server is running
  if server_running?(port)
    # Verify that the child process is still running
    if process_running?(pid)
      elapsed_time = Time.now - start_time
      STDOUT.puts "Web server started successfully in #{elapsed_time.round(2)} seconds".green
      success = true
      break
    else
      # Child process has exited despite the server being up
      exit_code = nil
      begin
        Process.waitpid(pid)
        exit_code = $?.exitstatus
      rescue Errno::ECHILD
        # No child process to wait for
      end
      STDERR.puts "Web server process exited unexpectedly with exit code: #{exit_code}".red
      success = false
      break
    end
  else
    # Check if the child process has exited prematurely
    begin
      pid_status = Process.waitpid(pid, Process::WNOHANG)
      if pid_status
        # Child process has exited
        exit_code = $?.exitstatus
        STDERR.puts "Web server process exited with exit code: #{exit_code}".red
        success = false
        break
      end
    rescue Errno::ECHILD
      # No child process exists
      STDERR.puts "No child process found.".red
      success = false
      break
    end

    # Check for timeout
    if Time.now - start_time > timeout
      STDERR.puts "Timeout reached: Web server did not start within #{timeout} seconds".red
      success = false
      break
    end

    # Wait before the next check
    sleep 0.5
  end
end

if success
  # Detach the child process to let it run independently
  Process.detach(pid)
  exit 0
else
  # Attempt to kill the child process if it's still running
  if process_running?(pid)
    begin
      Process.kill("TERM", pid)
      STDERR.puts "Terminated the web server process.".yellow
    rescue Errno::ESRCH
      STDERR.puts "Web server process already terminated.".yellow
    end
  end
  exit 1
end
