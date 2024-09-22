require 'colorize'
require 'pry'

# Assign values to variables
cmd = ARGV.last
timeout = 10

stdout_file = "/tmp/launch0_stdout_#{Process.pid}.log"
stderr_file = "/tmp/launch0_stderr_#{Process.pid}.log"

STDOUT.puts "Running command: #{cmd}"

# Fork a child process
pid = fork do
  # In child process

  # Start a new session to detach from the controlling terminal
  Process.setsid

  # Redirect stdin, stdout, and stderr
  $stdin.reopen('/dev/null')
  $stdout.reopen(stdout_file, 'w')
  $stderr.reopen(stderr_file, 'w')

  # Execute the command
  exec(cmd)
end

STDOUT.puts "Process PID: #{pid}"

success = false

STDOUT.puts 'Give it a time for the process to start...'

# Tail the output file during the timeout
stdout_tail_thread = Thread.new do
  File.open(stdout_file, 'r') do |file|
    file.seek(0, IO::SEEK_END) # Start at the end of the file
    loop do
      select([file])
      line = file.gets
      STDOUT.puts line if line
    end
  end
end

# Tail the output file during the timeout
stderr_tail_thread = Thread.new do
  File.open(stderr_file, 'r') do |file|
    file.seek(0, IO::SEEK_END) # Start at the end of the file
    loop do
      select([file])
      line = file.gets
      STDERR.puts line.red if line
    end
  end
end

# Sleep for the timeout duration
STDOUT.puts "Wait #{timeout} seconds before checking if process #{pid} is still running."
sleep timeout

# Check if the process is still running
begin
  state = `ps -p #{pid} -o state=`.strip
  if state.empty?
    STDERR.puts "Process #{pid} has exited.".red
  elsif state.include?('Z')
    STDERR.puts "Process #{pid} is defunct (zombie).".red
  else
    STDOUT.puts "Process #{pid} is still running after #{timeout} seconds.".green
    STDOUT.puts "Process spawning success.".green
    success = true
  end
rescue Errno::ESRCH
  STDERR.puts "Process #{pid} has exited.".red
end

# Stop tailing the output file
stdout_tail_thread.kill
stdout_tail_thread.join

stderr_tail_thread.kill
stderr_tail_thread.join

if success
  # Parent process exits, child continues running independently
  exit 0
else
  # Process has exited; exit with failure code
  exit 1
end
