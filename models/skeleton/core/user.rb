require 'sequel'
module BlackStack
    module MySaaS
        class User < Sequel::Model(:user)
            many_to_one :account, :class=>:'BlackStack::MySaaS::Account', :key=>:id_account
            one_to_many :preferences, :class=>:'BlackStack::MySaaS::Preference', :key=>:id_user

            # generate a random password from an id
            def self.default_password(uid)
                "#{uid[0..4]}123abc"
            end

            # generate a random password from the user.id
            def default_password
                self.class.default_password(self.id)
            end

            # get the type of the default parameter (string, integer, boolean, or float).
            # lookup for the name in the preference table.
            # if the name is not found, create a new record. 
            def preference(name, default, x=nil)
                type = nil
                
                # get the type of the default value
                type = BlackStack::MySaaS::Preference::type_of(default)
                if type.nil?
                    raise "Invalid default value for preference. Expected String, Integer, Float, or Boolean."
                end

                # get the preference
                p = BlackStack::MySaaS::Preference.where(:name=>name, :id_user=>self.id).first
                if p.nil?
                    p = BlackStack::MySaaS::Preference.new
                    p.id = guid
                    p.id_user = self.id
                    p.create_time = now
                    p.name = name
                    p.type = type
                    p.set_value(default)
                    p.save
                end

                # validate: the type of the preference is the same than the default value
                if p.type != type
                    raise "Invalid default value for preference. Expected #{BlackStack::MySaaS::Preference.type_name(p.type)}."
                end

                # if exists params[name], then update the value of the preference
                if !x.nil?
                    p.set_value(x)
                    p.save
                end

                # return the value of the preference
                p.get_value
            end # def preference 

            def pref(
                name:,
                default:,
                value: nil
            )
                self.preference(name, default, value)
            end

            def self.login(h)
                errors = []
                email = h[:email]
                password = h[:password]
      
                if email.to_s.size==0
                    errors << "Email is required."
                end
        
                if password.to_s.size==0
                    errors << "Password is required."
                end
                
                # comparar contra la base de datos
                # TODO: getting the right owner when we develop domain aliasing
                u = BlackStack::MySaaS::User.where(:email=>email).first 
        
                # decidir si el intento de l es exitoso o no
                if u.nil?
                    errors << "Email not found."
                end

                # reference: https://github.com/bcrypt-ruby/bcrypt-ruby#how-to-use-bcrypt-ruby-in-general
                #
                # And yes, the user can login with its password, or the crypted password too.
                # This is required to re-connect subaccounts, with their original passwords.
                #
                if !u.nil? && BCrypt::Password.new(u.password) != password && u.password != password
                    # TODO: register failed login attempt
                    # TODO: validate number of login attempts last hour
                    errors << "Wrong passsword."
                end

                # if there are errors, raise exception with errors
                if errors.size > 0
                    # libero recursos
                    DB.disconnect	
                    GC.start
                    raise errors.join("\n") 
                end
                
                # registro el login
                l = BlackStack::MySaaS::Login.new
                l.id = guid
                l.id_user = u.id
                l.create_time = now
                l.save

                # libero recursos
                DB.disconnect
                GC.start

                # return the new login object
                l
            end # def login

            # this method is user by either: recover passowrd by a logged-out user, or change password by a logged-in user.
            # current_password may be the raw password, or the crypted password.
            def change_password(current_password, new_password_1, new_password_2)
                errors = []

                # validate: current_password is required
                if current_password.to_s.size==0
                    errors << "Current password is required." 
                end

                # validate: current_password matches with the password of the user
                if BCrypt::Password.new(self.password) != current_password && self.password != current_password
                    errors << "Current password is wrong."
                end

                # validate: new_password_1 is required
                if new_password_1.to_s.size==0
                    errors << "New Password is Required."
                end

                # validate: new_password_2 is required
                if new_password_2.to_s.size==0
                    errors << "Repeat Password is Required."
                end

                # validar que la nueva password cumple con los requisitos de seguridad
                if !new_password_1.password?
                    errors << "Password is Not Secure. Password must have letters and number, and 6 chars as minimum."
                end

                # validar que las passwords coincidan
                if new_password_1 != new_password_2
                    errors << "Passwords do not match."
                end

                # if any error happened, then raise an exception
                if errors.size > 0
                    raise errors.join("\n")
                end

                # update password
                self.password = BCrypt::Password.create(new_password_1) # reference: https://github.com/bcrypt-ruby/bcrypt-ruby#how-to-use-bcrypt-ruby-in-general
                self.save
            end

            # signup a new user to the same account of this user.
            # return the new user object.
            def add_user(h, notif=true)
                # security validation: this user must be the owner of the account
                if !self.account_owner?
                    raise "You are not the owner of this account. Only account owner can add users."
                end

                # add the user to the account
                u = self.account.add_user(h)
                
                # return
                u
            end

            def update_users(h, notif=false)
                # update users
                u = self.account.update_users(h)

                # send notification to the new user
                u.notification_you_have_been_added = true
                u.save
            end

            # signup a new user to the same account of this user.
            # return the new user object.
            def remove_users(h) 
                # security validation: this user must be the owner of the account
                if !self.account_owner?
                    raise "You are not the owner of this account. Only account owner can remove users."
                end

                # add the user to the account
                u = self.account.remove_users(h)
                
                # TODO: add parameter notif=true
                # TODO: send notification to the old user
    
                # return
                u
            end

            # set the current time to self.delete_time.
            # append a guid to the email address, in order to allow the user to create a new account using the old email.
            def remove
                self.delete_time = now
                self.email = self.email + "-deleted-" + guid
                self.save
            end

            # update user
            def update(h)
                self.email = h[:email]
                self.name = h[:name]
                self.phone = h[:phone]
                self.save
            end

            # assign another user as the owner of this user's account
            def set_account_owner(h)
                errors = []
                user = nil

                # security validation: this user must be the owner of the account
                if !self.account_owner?
                    errors << "You are not the owner of this account. Only account owner can assign account owner."
                end

                # validate: h[:id_user] is required
                if h[:id_user].to_s.size==0
                    errors << "User ID is required."
                end

                # validate: h[:id_user] is a valid guid
                if !h[:id_user].to_s.guid?
                    errors << "User ID is not a valid guid."
                end

                if errors.size == 0                                
                    # validate: h[:id_user] is a valid user
                    user = BlackStack::MySaaS::User.where(:id=>h[:id_user]).first
                    if user.nil?
                        errors << "User #{h[:id_user]} not found."
                    end

                    # security validation: both users must be in the same account
                    if !user.nil?
                        if self.account.id.to_guid != user.account.id.to_guid
                            errors << "Both users must be in the same account."
                        end
                    end
                end

                # if any error happened, then raise an exception
                if errors.size > 0
                    raise errors.join("\n")
                end

                # perform the operation
                self.account.id_user_to_contact = user.id
                self.account.save
            end

            # send a confirmation email to a user of this account
            def send_confirmation_email(h)
                errors = []
                user = nil

                # validate: h[:id_user] is required
                if h[:id_user].to_s.size==0
                    errors << "User ID is required."
                end

                # validate: h[:id_user] is a valid guid
                if !h[:id_user].to_s.guid?
                    errors << "User ID is not a valid guid."
                end

                if errors.size == 0                                
                    # validate: h[:id_user] is a valid user
                    user = BlackStack::MySaaS::User.where(:id=>h[:id_user]).first
                    if user.nil?
                        errors << "User #{h[:id_user]} not found."
                    end

                    # security validation: both users must be in the same account
                    if !user.nil?
                        if self.account.id.to_guid != user.account.id.to_guid
                            errors << "Both users must be in the same account."
                        end
                    end
                end

                # if any error happened, then raise an exception
                if errors.size > 0
                    raise errors.join("\n")
                end

                # perform the operation
                user.notification_confirm_email_requested = true
                user.save
            end

            # return true if this user is the owner of its account.
            # return false if this user is not the owner of its account.
            def account_owner?
                self.account.user_owner.id.to_guid == self.id.to_guid
            end
        end # class User
    end # module MySaaS
end # module BlackStack