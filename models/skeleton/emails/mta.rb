module BlackStack
    module Emails
        class Mta < Sequel::Model(:eml_mta)
            many_to_one :user, :class=>:'BlackStack::MySaaS::User', :key=>:id_user
            one_to_many :addresses, :class=>:'BlackStack::Emails::Address', :key=>:id_mta

            VALID_AUTHENTICATION_VALUES = ['plain', 'login', 'cram_md5', 'none']
            VERIFY_MODES = [
                OpenSSL::SSL::VERIFY_NONE, 
                OpenSSL::SSL::VERIFY_PEER, 
                OpenSSL::SSL::VERIFY_FAIL_IF_NO_PEER_CERT, 
                OpenSSL::SSL::VERIFY_CLIENT_ONCE
            ]

            # this ugly patch is to save the situation when the hash is submited by an HTML form, where all the values are strings.
            def self.format_descriptor_received_from_html_form(h)
                h[:enable_starttls_auto] = true if h[:enable_starttls_auto].to_s == 'true'
                h[:enable_starttls_auto] = false if h[:enable_starttls_auto].to_s == 'false'
                h[:openssl_verify_mode] = h[:openssl_verify_mode].to_i if !h[:openssl_verify_mode].nil?
                h
            end

            # validate hash descriptor
            # TODO: move this to a base module, in order to  develop a stub-skeleton/rpc model.
            def self.validate_descriptor(h)
                # list of errors found
                errors = []
                # validate: h must be a hash
                errors << 'h is not a hash' unless h.is_a?(Hash)
                # if h is a hash
                if h.is_a?(Hash)
                    # this ugly patch is to save the situation when the hash is submited by an HTML form, where all the values are strings.
                    h = BlackStack::Emails::Mta.format_descriptor_received_from_html_form(h)
                    # validate: id_user is mandatory
                    errors << 'id_user is mandatory' unless h[:id_user] 
                    
                    # validate: smtp_address is mandatory
                    errors << 'smtp_address is mandatory' unless h[:smtp_address]
                    # validate: smtp_port is mandatory
                    errors << 'smtp_port is mandatory' unless h[:smtp_port]

                    # validate: imap_address is mandatory
                    errors << 'imap_address is mandatory' unless h[:imap_address]
                    # validate: imap_port is mandatory
                    errors << 'imap_port is mandatory' unless h[:imap_port]
    
                    # validate: id_user is an uuid
                    errors << 'id_user is not an uuid' if h[:id_user] && !h[:id_user].to_s.guid?
                    # validate: user exists
                    errors << 'user does not exists' if h[:id_user] && BlackStack::MySaaS::User.where(:id=>h[:id_user]).first.nil?

                    # validate: smtp_address is a string
                    errors << 'smtp_address is not a string' if h[:smtp_address] && !h[:smtp_address].is_a?(String)
                    # validate: smtp_port is an integer
                    errors << 'smtp_port is not an integer' if h[:smtp_port] && !h[:smtp_port].to_s =~ /^\d+$/
                    
                    # validate: imap_address is a string
                    errors << 'imap_address is not a string' if h[:imap_address] && !h[:imap_address].is_a?(String)
                    # validate: imap_port is an integer
                    errors << 'imap_port is not an integer' if h[:imap_port] && !h[:imap_port].to_s =~ /^\d+$/

                    # validate: if :authentication exists, it must be a valid value
                    errors << "authentication is not a valid value (#{VALID_AUTHENTICATION_VALUES.join(', ')})" if h[:authentication] && !VALID_AUTHENTICATION_VALUES.include?(h[:authentication])

                    # validate: if :enable_starttls_auto exists, it must be a boolean
                    errors << 'enable_starttls_auto is not a boolean' if h[:enable_starttls_auto] && !h[:enable_starttls_auto].is_a?(TrueClass) && !h[:enable_starttls_auto].is_a?(FalseClass)

                    # validate: if :openssl_verify_mode it must be a valid value
                    errors << "openssl_verify_mode (#{h[:openssl_verify_mode].to_s}) is not a valid value (#{VERIFY_MODES})" if h[:openssl_verify_mode] && !VERIFY_MODES.include?(h[:openssl_verify_mode])        
                end # if h.is_a?(Hash)
                # return
                return errors.uniq
            end # self.validate_descriptor

            # map a hash descriptor to the object attributes
            def initialize(h)
                # this ugly patch is to save the situation when the hash is submited by an HTML form, where all the values are strings.
                h = BlackStack::Emails::Mta.format_descriptor_received_from_html_form(h)
                # create Sequel object
                super()
                # validate h
                errors = self.class.validate_descriptor(h)
                # raise exception if there is errors
                raise errors.join(', ') if errors.size > 0
                # map attributes
                self.id = guid
                self.create_time = now
                self.id_user = h[:id_user]

                self.smtp_address = h[:smtp_address]
                self.smtp_port = h[:smtp_port].to_i
                self.smtp_username = h[:smtp_username]
                self.smtp_password = h[:smtp_password]

                self.imap_address = h[:imap_address]
                self.imap_port = h[:imap_port].to_i
                self.imap_username = h[:imap_username]
                self.imap_password = h[:imap_password]

                self.authentication = h[:authentication] || 'plain'
                self.enable_starttls_auto = h[:enable_starttls_auto] || true
                self.openssl_verify_mode = h[:openssl_verify_mode] || OpenSSL::SSL::VERIFY_NONE
                self.inbox_label = h[:inbox_label]
                self.spam_label = h[:spam_label]
                self.search_all_wildcard = h[:search_all_wildcard]
            end

            # return a hash descriptor from the object attributes
            def to_hash
                {
                    :id=>self.id,
                    :create_time=>self.create_time,
                    :id_user=>self.id_user,
                    
                    :smtp_address=>self.smtp_address,
                    :smtp_port=>self.smtp_port,
                    :smtp_username=>self.smtp_username,
                    :smtp_password=>self.smtp_password,

                    :imap_address=>self.imap_address,
                    :imap_port=>self.imap_port,
                    :imap_username=>self.imap_username,
                    :imap_password=>self.imap_password,

                    :authentication=>self.authentication,
                    :enable_starttls_auto=>self.enable_starttls_auto,
                    :openssl_verify_mode=>self.openssl_verify_mode,
                }
            end

            # return an Mta object belonging the account of the user, with the same smtp and imap addresses and ports.
            def self.load(h)
                u = BlackStack::Emails::User.where(:id=>h[:id_user]).first
                row = DB["
                    SELECT m.id 
                    FROM eml_mta m
                    JOIN \"user\" u ON ( u.id=m.id_user AND u.id_account='#{u.id_account}' )

                    WHERE m.smtp_address='#{h[:smtp_address]}' 
                    AND m.smtp_port='#{h[:smtp_port]}' 
                    AND m.smtp_username #{h[:smtp_username] ? "='#{h[:smtp_username]}'" : 'IS NULL'}
                    AND m.smtp_password #{h[:smtp_username] ? "='#{h[:smtp_password]}'" : 'IS NULL'}

                    AND m.imap_address='#{h[:imap_address]}' 
                    AND m.imap_port='#{h[:imap_port]}'
                    AND m.imap_username #{h[:smtp_username] ? "='#{h[:imap_username]}'" : 'IS NULL'}
                    AND m.imap_password #{h[:smtp_username] ? "='#{h[:imap_password]}'" : 'IS NULL'}

                "].first
                return nil if row.nil?
                return BlackStack::Emails::Mta.where(:id=>row[:id]).first
            end

            # return true if the user's account already has an MTA record with these settings
            def self.exists?(h)
                !BlackStack::Emails::Mta.load(h).nil?
            end

            # return true if the user's account already has an MTA record with these settings
            def exists?
                !BlackStack::Emails::Mta.exists?(self.to_hash).nil?
            end
        end # class Mta
    end # module Emails
end # BlackStack