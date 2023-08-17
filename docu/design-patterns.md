# a03. Design Patterns

A **design pattern** systematically names, motivates, and explains a general design that addresses a recurring desing problem in object-oriented systems. It describes the problem, the solution, when to apply the solution, and its consequences. It also gives implementation hints and examples [[1](https://people.cs.vt.edu/~kafura/cs2704/design.patterns.html)].

This tutorial introduces the typical design problems we face when develop MySaaS's extensions, and a standard solution to resolve each one of them. 

Here is the list of design patterns in this document:

1. [Basic Filter](#a031-basic-filter)
2. [Reusable Filter](#a032-reusable-filter)
3. [Access Point](#a033-access-point)
4. [RPC Stub-Skeleton](#a034-rpc-stub-skeleton)
5. [Configuration Module](#a035-configuration-modules)
6. [Configuration Service](#a036-configuration-service)

## a03.1. Basic Filter

You have a web form (account.erb) to update some information regarding the account.

The information submited by the user is pushed to another page called **filter**.
The filter is a pure-erb file, whith no HTML. Only Ruby code is present in the **filter**.

**account.erb**
```html
<form class="form-horizontal" action="filter_account" method="post">
	<div class="control-group span12">
		<label class="control-label" for="inputKeywords">Company Name</label>
		<div class="controls">
			<input type="text" class="input-xlarge" name="name" id="name" placeholder="Write your Company to be used for the invoicing" value="<%=account.name.encode_html%>">
		</div>
		<br/>							
		<div class="controls">
			<button type="submit" id="update" class="btn btn-blue">Update</button>
			<a id="cancel" class="btn btn-default" href='/settings'>Cancel</a>
		</div>
	</div>
</form>
```

**filter_account.erb**
```ruby
<%
account = @login.user.account
name = params[:name]

# validate: name is required
if name.to_s.size==0
	redirect "/settings/account?err=#{CGI::escape("Company Name is Required.")}"
end

# validate: name cannot be longer then 100 characters
if name.to_s.size>100
	redirect "/settings/account?err=#{CGI::escape("Company Name cannot be longer then 100 characters.")}"
end

# save
account.name = name
account.id_timezone = id_timezone
account.save

redirect "/settings/account?msg=#{CGI::escape("Information Updated.")}"
%>
```

Both `account.erb` and `filter_account.erb` are defined in the `app.rb` file:

**app.rb**
```ruby
# account information
get '/settings/account', :auth => true, :agent => /(.*)/ do
  erb :'views/settings/account', :layout => :'/views/layouts/core'
end

post '/settings/filter_account', :auth => true do
  erb :'views/settings/filter_account'
end
```

**Some considerations:**

1. The `auth` condition requires a logged in user to access these pages, but also generates the `@login` object, from where you can grab the logged in user.
You can find the source code of the `auth` condition here: [https://github.com/leandrosardi/mysaas/blob/0.0.3/app.rb#L68](https://github.com/leandrosardi/mysaas/blob/0.0.3/app.rb#L68).

2. The `:layout => :'/views/layouts/core'` embbeds the code of `account.erb` into another **HTML template** who includes the topbar, the leftbar, the footer, and the invokes of all the required stylsheets and javascript files.
You can find the source code such an **HTML template** condition here: [https://github.com/leandrosardi/mysaas/blob/0.0.3/views/layouts/core.erb](https://github.com/leandrosardi/mysaas/blob/0.0.3/views/layouts/core.erb).

3. The same **HTML tamplate** process the GET parameters `?err=` and `?msg=` returned by `filter_account.erb`, and show them in the screen.  
You can find the processing of both `?erro=` and `?msg=` here: [https://github.com/leandrosardi/mysaas/blob/0.0.3/views/templates/header.erb#L127](https://github.com/leandrosardi/mysaas/blob/0.0.3/views/templates/header.erb#L127).

4. Both `account.erb` and `filter_account.erb` are belonging the `views` folder, where all the files regarding the screen are placed.

## a03.2. Reusable Filter

The filter `filter_account.erb` in the previous example may be improved, but developing a method `account.update(params)` who receive the form parameters of `account.erb`.

**account.rb**
```ruby
module BlackStack
    module MySaaS
        class Account < Sequel::Model(:account)
            def update(params)
                errors = []

                # validate: name is required
                if params[:name].to_s.size==0
                    errors << "Company Name is Required."
                end

                # validate: name cannot be longer then 100 characters
                if params[:name].to_s.size>100
                    errors << "Company Name cannot be longer then 100 characters."
                end

                # if any error happened, then raise an exception with all the errors.
                if errors.size
                    raise errors.join("\n")
                end 

                # update
                self.name = params[:name]
                self.save
            end
        end # class Account
    end # module MySaaS
end # module BlackStack
```

**filter_account.erb**
```ruby
<%
begin
    @login.user.account.update(params)
    redirect "/settings/account?msg=#{CGI::escape("Information Updated.")}"
rescue => e
    redirect "/settings/account?err=#{CGI::escape(e.message)}"
end
%>
```

**Some considerations:**

1. The reason to develop **Reusable Filters** instead **Basic Filters** is because may need to call the `update(params)` method (with all its validations) from other filters. In the next patter (**Access Points**) we are going to reuse the the `update(params)` method from an access point.

2. The `BlackStack::MySaaS::Account` class inherits from `Sequel::Model` that means it is part of the ORM (Object Relational Mapping). That means that the each instance (object) of the `Account` class is a record in the `account` table in the database.

3. **ORM classes** are also called **Skeleton**. This concept is taken in the **RPC** design pattern explained below.

4. The `account.rb` file is belonging the `models` folder, where all the ORM classes are placed.

5. The `update(params)` method raises exceptions instead of redirecting to the `account.erb` screen. Since the `update(params)` method is part of a **model** class, it should be called from a backend process too. So, the `update(params)` method should never reference any file beloning the **view**.
 
## a03.3. Access Point

Very often, end-users want an API for import or export infrmation from our APP, or for connecting our APP with other tools.

Even when end-users have not technical skills, they are familiarized with integration tools like [Zapier](https://zapier.com/).

An **access point** is very similar to a **filter**. So, we can reuse the **filters**'s code.

**app.rb**
```ruby
# mysaas
post '/api1.0/mysaas/account/update.json', :api_key => true do
    begin
        @account.update(params)
    rescue => e
        @return_message[:status] = e.message
    end
    halt @return_message.to_json
end
```

**Some considerations:**

1. The `api_key` condition generates the variable `@account` from the `api_key` parameter provided by the user. That means: the **access point** receives the same paramaters than the filter `filter_account.erb`, plus an additional parameter `:api_key` that is the secret key of the account.

2. The access point can be called using `post` method only. The `get` method is not secure when it receive secret information like a password or the `api_key` in this case.

3. The `api_key` condition generates the variable `@return_message` with the value `{:status=>'success'}` by default. 

4. The `api_key` condition performs some validations too. Example: if the API key has a wrong format, or if there is not any account with such an api-key.

You can find the source code of the `api_key` condition here: [https://github.com/leandrosardi/mysaas/blob/0.0.3/app.rb#L81](https://github.com/leandrosardi/mysaas/blob/0.0.3/app.rb#L81).

## a03.4. RPC Stub-Skeleton

Very often, you may need to write processes who work remotely (outside the LAN), with no direct connection to the database.

Such processes must use the **access points** (API) to operate the database.

A **stub** classs has similar methods than the **skeleton** class (a.k.a. the ORM class), but calling the access points to perform the operation.



```ruby
# User stub
module BlackStack
    module MySaaS
        class Account
            def update(params)
                res = nil
                url = "#{CS_HOME_WEBSITE}/api1.0/mysaas/account/update.json"
                params[:api_key] = my_api_key
                begin
                    res = BlackStack::Netting::call_post(url, params)
                rescue Errno::ECONNREFUSED => e
                    sError = "Errno::ECONNREFUSED:" + e.message
                rescue => e2
                    sError = "Exception:" + e2.message
                end
                parsed = JSON.parse(res.body)
                raise parsed['status'] if parsed['status']!='success'
            end
        end
    end # module MySaaS
end # module BlackStack
```

## a03.5. Configuration Modules

_(pending)_

Examples: `BlackStack::Emails`, `BlackStack::Notifications`

## a03.6. Configuration Service

_(pending)_

Examples: 

1. `BlackStack::Extensions` who can register extensions in the ConnectionSphere's database;

2. `BlackStack::Pampa` who can register worker processes in the ConnectionSphere's database;


