module BlackStack
  module Deployment
    @@nodes = []

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
      @@nodes << h
    end # def self.add_node(h)

    # 
    def self.get_node(node_name)
      @@nodes.find { |n| n[:name] == node_name }
    end # def self.get_node(node_name)

    # 
    def self.install(
      node_name,
      logger: nil,
      bash_script_url: 'https://raw.githubusercontent.com/leandrosardi/environment/main/sh/install.ubuntu.20_04.simplified.sh'
    )
      l = logger || BlackStack::DummyLogger.new(nil)

      l.logs "Getting node #{node_name.blue}... "
      n = get_node(node_name)
      raise ArgumentError, "Node not found: #{node_name}" if n.nil?
      n = n.clone # clone the hash descriptor, because I will modify it below.
      l.done

      # download the file from the URL
      l.logs "Downloading bash script from #{bash_script_url.blue}... "
      bash_script = Net::HTTP.get(URI(bash_script_url))
      l.done(details: "#{bash_script.length} bytes downloaded")

      # switch user to root and create the node object
      l.logs "Creating node object... "
      new_ssh_username = n[:ssh_username]
      new_hostname = n[:name]
      n[:ssh_username] = 'root'
      n[:ssh_password] = n[:ssh_root_password]
      node = BlackStack::Infrastructure::Node.new(n)
      l.done

      l.logs('Connect to node demo-node... ')
      node.connect
      l.done
      # => n.ssh

      # execute the script line by line
      bash_script.each_line { |line|
        line.strip!
        next if line.empty?
        next if line.start_with?('#')          
        l.logs "#{line.blue}... "        
        line.gsub!('$1', new_hostname)
        line.gsub!('$2', new_ssh_username)
        l.done(details: node.exec(line))
      }

      l.logs 'Disconnect from node demo-node... '
      node.disconnect
      l.done

    end # def self.install(node_name, logger: nil)


  end # Deployment
end # BlackStack
  