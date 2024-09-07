module BlackStack
  module Deployment
    @@nodes = []

    # Validates that the environment variable SAASLIB is defined.
    #
    # This function checks if the environment variable SAASLIB is set.
    # If SAASLIB is not defined, it raises a RuntimeError with an appropriate message.
    # 
    # @raise [RuntimeError] If the SAASLIB environment variable is not defined.
    #
    # @example
    #   validate_saaslib_env
    #   # If SAASLIB is not defined, this will raise an exception with the message:
    #   # "Environment variable SAASLIB is not defined."
    #
    def self.validate_saaslib_env
      unless ENV['SAASLIB']
        raise "Environment variable SAASLIB is not defined."
      end
    end

    # Reference:
    # https://github.com/MassProspecting/docs/issues/254
    #
    # Executes a given bash command, redirecting its standard output and error output to specified files.
    # 
    # The output and error files are cleaned (truncated) before the command is executed.
    # If the command produces any error output, an exception is raised with the error message.
    # If the command executes successfully, the content of the standard output is returned.
    # 
    # By default, the output and error files are located in the directory specified by the $SAASLIB environment variable.
    # 
    # @param command [String] The bash command to be executed.
    # @param output_file [String] (default: '$SAASLIB/output.txt') The file where standard output will be redirected.
    # @param error_file [String] (default: '$SAASLIB/error.txt') The file where standard error will be redirected.
    # 
    # @return [String] The content of the standard output if the command executes successfully.
    # 
    # @raise [RuntimeError] If the command produces any error output, the exception will contain the error message.
    # 
    # @example Basic usage
    #   begin
    #     output = execute_command('ls /some_directory')
    #     puts output
    #   rescue => e
    #     puts e.message
    #   end
    #
    def self.execute_command(command, output_file: "#{ENV['SAASLIB']}/bash-command-stdout-buffer", error_file: "#{ENV['SAASLIB']}/bash-command-stderr-buffer")
      # Clean the output and error files before execution
      File.open(output_file, 'w') {} # Truncate the output file
      File.open(error_file, 'w') {}  # Truncate the error file

      # Execute the command, redirecting stdout to the output file and stderr to the error file
      system("#{command} > #{output_file} 2> #{error_file}")

      # Check if the error file has any content
      if File.size?(error_file)
        # Read the error message
        error_message = File.read(error_file)
        # Raise an exception with the error message
        raise "Command failed with the following error:\n#{error_message}"
      end

      # If no error, read and return the content of the output file
      File.read(output_file)
    end
  
    def self.nodes
      @@nodes
    end # nodes




    def self.add_node(h)
      err = []

      # Set default values for optional keys if they are missing
      h[:dev] ||= false
      h[:net_remote_ip] ||= nil
      h[:provider] ||= :contabo
      h[:procs] ||= {}
      h[:logs] ||= []
      h[:webs] ||= []

      # Validate the presence and format of the mandatory keys
      if h[:name].nil? || !h[:name].is_a?(String) || h[:name].strip.empty?
        err << "Invalid value for :name. Must be a non-empty string."
      end

      if ![true, false].include?(h[:dev])
        err << "Invalid value for :dev. Must be a boolean."
      end

      if h.key?(:net_remote_ip) && !h[:net_remote_ip].nil?
        unless h[:net_remote_ip] =~ /\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b/
          err << "Invalid value for :net_remote_ip. Must be a valid IP address or nil."
        end
      end

      if h[:provider] != :contabo
        err << "Invalid value for :provider. Allowed values: [:contabo]."
      end

      if h[:service].nil? || !['CLOUD VPS 1', 'CLOUD VPS 3', 'CLOUD VPS 6'].include?(h[:service])
        err << "Invalid value for :service. Allowed values: ['CLOUD VPS 1', 'CLOUD VPS 3', 'CLOUD VPS 6']."
      end

      if h[:db_host].nil? || !h[:db_host].is_a?(String) || h[:db_host].strip.empty?
        err << "Invalid value for :db_host. Must be a non-empty string."
      end

      required_ssh_keys = [:ssh_username, :ssh_port, :ssh_password, :ssh_root_password]
      required_ssh_keys.each do |key|
        if h[key].nil?
          err << "Missing required SSH key: #{key}"
        elsif key == :ssh_port
          unless h[:ssh_port].is_a?(Integer) && h[:ssh_port] > 0 && h[:ssh_port] < 65536
            err << "Invalid value for :ssh_port. Must be an integer between 1 and 65535."
          end
        elsif !h[key].is_a?(String) || h[key].strip.empty?
          err << "Invalid value for #{key}. Must be a non-empty string."
        end
      end

      required_git_keys = [:git_repository, :git_branch, :git_username, :git_password]
      required_git_keys.each do |key|
        if h[key].nil?
          err << "Missing required Git key: #{key}"
        elsif key == :git_repository
          unless h[:git_repository].is_a?(String) && h[:git_repository].match?(/^[A-Za-z0-9._-]+\/[A-Za-z0-9._-]+$/)
            err << "Invalid value for :git_repository. Must be a valid GitHub repository path."
          end
        elsif !h[key].is_a?(String) || h[key].strip.empty?
          err << "Invalid value for #{key}. Must be a non-empty string."
        end
      end

      if h[:code_folder].nil? || !h[:code_folder].is_a?(String) || !h[:code_folder].start_with?('/')
        err << "Invalid value for :code_folder. Must be an absolute Linux path."
      end

      if h.key?(:procs)
        unless h[:procs].is_a?(Hash)
          err << "Invalid value for :procs. Must be a hash."
        end

        if h[:procs].key?(:start)
          unless h[:procs][:start].is_a?(Array)
            err << "Invalid value for :procs[:start]. Must be an array of commands."
          end

          h[:procs][:start].each do |proc|
            unless proc.is_a?(Hash) && proc.key?(:command) && proc[:command].is_a?(String)
              err << "Invalid start process. Each must be a hash with a :command key."
            end
          end
        end

        if h[:procs].key?(:stop)
          unless h[:procs][:stop].is_a?(Array) && h[:procs][:stop].all? { |cmd| cmd.is_a?(String) }
            err << "Invalid value for :procs[:stop]. Must be an array of strings."
          end
        end
      end

      if h.key?(:logs)
        unless h[:logs].is_a?(Array) && h[:logs].all? { |log| log.is_a?(String) }
          err << "Invalid value for :logs. Must be an array of strings."
        end
      end

      if h.key?(:webs)
        unless h[:webs].is_a?(Array)
          err << "Invalid value for :webs. Must be an array of websites."
        end

        h[:webs].each do |web|
          unless web.is_a?(Hash) && web[:name].is_a?(String) && !web[:name].strip.empty? &&
                 web[:port].is_a?(Integer) && web[:port] > 0 && web[:port] < 65536 &&
                 [:http, :https].include?(web[:protocol])
            err << "Invalid web configuration. Each must be a hash with :name, :port, and :protocol."
          end
        end
      end

      # Raise exception if any errors were found
      raise ArgumentError, "The following errors were found in My.SaaS node descriptor: \n#{err.map { |s| " - #{s}" }.join("\n")}" unless err.empty?

      # Create and add the node
      node = BlackStack::Infrastructure::Node.new(h)
      @@nodes << node
    end



  end # Deployment
end # BlackStack
  