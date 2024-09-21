require 'net/http'
require 'timeout'
require 'simple_command_line_parser'
require 'colorize'

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
    :default => 10,
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
  rescue Errno::ECONNREFUSED, Errno::EADDRNOTAVAIL, Timeout::Error
    return false
  end
end

# Define the command to run the web server
cmd = "cd #{parser.value('path')} && ruby app.rb port=#{parser.value('port')} config=#{parser.value('config')} &"

STDOUT.puts "Running command: #{cmd}"

# Create pipes for stdout and stderr
stdout_read, stdout_write = IO.pipe
stderr_read, stderr_write = IO.pipe

# Spawn the process with stdout and stderr redirected to the pipes
pid = Process.spawn(cmd, out: stdout_write, err: stderr_write)

# Close the write ends in the main process as they are now connected to the child process
#stdout_write.close
#stderr_write.close

# Start threads to read from the pipes and forward to main stdout and stderr
stdout_thread = Thread.new do
  begin
    stdout_read.each_line do |line|
      STDOUT.puts "app STDOUT: #{line}"
    end
  rescue IOError
    # Handle IO errors if necessary
  end
end

stderr_thread = Thread.new do
  begin
    stderr_read.each_line do |line|
      STDERR.puts "app STDERR: #{line}"
    end
  rescue IOError
    # Handle IO errors if necessary
  end
end

# Check if the server is responding
success = false
start_time = Time.now

STDOUT.puts "Waiting for web server to start..."

loop do
  if server_running?(parser.value('port'))
    elapsed_time = Time.now - start_time
    STDOUT.puts "Web server started successfully in #{elapsed_time.round(2)} seconds".green
    success = true
    break
  else
    sleep 0.5
    if Time.now - start_time > parser.value('timeout')
      STDOUT.puts "Timeout reached: Web server did not start within #{parser.value('timeout')} seconds".red
      break
    end
  end
end

# Close the read ends of the pipes to signal EOF to the threads
stdout_read.close unless stdout_read.closed?
stderr_read.close unless stderr_read.closed?

# Wait for the threads to finish
#stdout_thread.join
#stderr_thread.join

if success
  # Detach the child process to let it run independently
  Process.detach(pid)
  exit 0
else
  # Attempt to kill the child process
  begin
    Process.kill("TERM", pid)
    STDOUT.puts "Terminated the web server process.".yellow
  rescue Errno::ESRCH
    STDOUT.puts "Web server process already terminated.".yellow
  end
  exit 1
end
