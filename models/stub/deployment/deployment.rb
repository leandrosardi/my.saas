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
      validate_saaslib_env

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

    def self.add_node(h)
    end # add_node

    def self.nodes
      @@nodes
    end # nodes

  end # Deployment
end # BlackStack
  