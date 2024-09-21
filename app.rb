require 'open3'
require 'net/http'
require 'timeout'
require 'simple_command_line_parser'
require 'colorize'

# --------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Parsing command line parameters.
# 
parser = BlackStack::SimpleCommandLineParser.new(
  :description => 'This command will launch a Sinatra-based BlackStack webserver in background, returning an exit code 0 if the async process started successfully or 1 of the async process failed to start.', 
  :configuration => [{
    :name=>'path', 
    :mandatory=>false, 
    :description=>'Folder where the script `app-sync.rb` is located.', 
    :type=>BlackStack::SimpleCommandLineParser::STRING,
    :default => '.',
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
  rescue Errno::ECONNREFUSED, Timeout::Error
    return false
  end
end

# Define the command to run the web server
cmd = "ruby #{parser.value('path')}/app-sync.rb port=#{parser.value('port')} config=#{parser.value('config')}"
  
# Run the command in the background
STDOUT.puts "Running command: #{cmd}"
stdin, stdout, stderr, wait_thr = Open3.popen3(cmd)
    
# Check if the server is responding
success = false
start_time = Time.now

# Retry until the server is running or the timeout is reached
STDOUT.puts "Waiting for web server to start... "
while true do 
  if server_running?(parser.value('port'))
    puts "Web server started successfully"
    success = true
    break
  else
    # wait half a second before retrying
    sleep 0.5 
    # if current time - start time > timeout (in seconds), exit
    break if Time.now - start_time > parser.value('timeout')
  end
end

STDOUT.puts "STDOUT: #{stdout.read}"
STDERR.puts "STDERR: #{stderr.read}"

if success
  # Get the exit status of the process
  exit_status = wait_thr.value.exitstatus
  if exit_status == 0
    STDOUT.puts "Web server started successfully.".green
  else
    STDERR.puts "Web server failed to start. Exit status: #{exit_status}".red
  end
  exit exit_status
else
  STDERR.puts "Web server failed to start".red
  Process.kill("TERM", wait_thr.pid) # Terminate the server process
  exit 1
end