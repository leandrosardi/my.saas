![GitHub issues](https://img.shields.io/github/issues/leandrosardi/my.saas) ![GitHub](https://img.shields.io/github/license/leandrosardi/my.saas) ![GitHub tag (latest by date)](https://img.shields.io/github/v/tag/leandrosardi/my.saas) ![GitHub last commit](https://img.shields.io/github/last-commit/leandrosardi/my.saas)

![logo](./public/core/images/logo.png)

# MySaaS - Open Source SaaS Platform - Extensible and Scalable.  

**MySaaS** is an open-source, extensible and scalable platform for develop your own Software as a Service (SaaS), e-Commerce, Education Platform, Social Network, Forum or any kind of memberships based product.

![Example of What Can You Create with My.SaaS](./docu/thumbnails/dashboard.png)

**Outline:**

1. [Features](#1-features)
2. [Getting Started](#2-getting-started)
3. [Running Scripts](#3-running-scripts)
4. [Models](#4-models)
5. [Screens](#5-screens)

5. [Filters](#5-filers)
6. [Access Points](#6-access-points)

Configuration

- changing deloyment output file
- changing `MYSAAS_API_KEY`
- setting `DROPBOX_REFRESH_TOKEN`

## 1. Features

Here is a full list of the MySaaS features:

**Fast Front-End Coding:**

- :heavy_check_mark: Vast pool of JavaScript components for an imporved UX.
- :heavy_check_mark: Vast pool of CSS entities for a nice UI.
- :heavy_check_mark: Funnel configuration with JSON descriptors.

**Deployment Automation:**

- :heavy_check_mark: Automated installation CLI command.
- :heavy_check_mark: Automated deployment CLI command.
- :heavy_check_mark: Automated backing up and restoring of secret files that you can't store in repositories  ([DropBox](https://www.dropbox.com)).

**Scalability:**

- :heavy_check_mark: Infrasctructure as a Code (IaaC) capabilities for running a mesh of offline processes.
- :heavy_check_mark: Scalable architecture: 
	- [AWS EC2](https://aws.amazon.com/ec2/) for scaleble webservers;
	- [Dropbox API](https://aws.amazon.com/ebs/) for elastic storage; and 
	- [CockroachDB](https://www.cockroachlabs.com/) for scalable and serverless database.

**End-Users Management:**

- :heavy_check_mark: Transactional emails ([Postmark](https://postmarkapp.com/)).
- :heavy_check_mark: PayPal integration for Invoicing & Payments Processing ([I2P](https://github.com/leandrosardi/i2p)).

**Extensibility:**

- :heavy_check_mark: Easy modules development.
- :heavy_check_mark: Advanced JavaScript components:
	- [Filters.js](https://github.com/leandrosardi/filtersjs);
	- [Templates.js](https://github.com/leandrosardi/templatesjs); 
	- [Editables.js](https://github.com/leandrosardi/editablesjs); 
	- [Timelines.js](https://github.com/leandrosardi/templatesjs); 
	- [Progress.js](https://github.com/leandrosardi/progressjs);
	- [Lists.js](https://github.com/leandrosardi/listsjs); and
	- [Datas.js](https://github.com/leandrosardi/datasjs).

## 2. Getting Started

On a fresh installation of Ubuntu 20.04, and using the `root` user, run the commands below:

**Step 1:** Run the **Environment Installation Script**.

Download our Environment Installation Script (or simply EIS) by running the lines below:

```
cd ~
wget https://raw.githubusercontent.com/leandrosardi/environment/main/sh/install.ubuntu.20_04.sh
```

Then run the EIS by running the line below, replacing the merge-tags

- `<hostname>` with the name you have to assisng the the node where my.saas will run; and
- `<password>` with the password you want for a new Linux user called `blackstack` who will be created by the EIS.

```
bash install.ubuntu.20_04.sh <hostname> <password>
```

**Note:** For running this example, use the values `dev2` and `blackstack123`. E.g.:

```
bash install.ubuntu.20_04.sh dev2 blackstack123
```

**Note:** Refer to [this other repository](https://github.com/leandrosardi/environment) for more information about the Environment Installation Script.

**Step 2:** Switch from `root` to the new `blackstack` user.

```bash
sudo su - blackstack
```

**Step 3:** Clone my.saas.

```bash
mkdir ~/code
cd ~/code
git clone https://github.com/leandrosardi/my.saas
```

```bash
cd ~/code/my.saas
git switch dev-1.6.7
git fetch --all
git reset --hard origin/dev-1.6.7
```

**Step 4:** Update gems.

```bash
cd ~/code/my.saas
bundler update
```

**Step 5:** Create a configuration file.

```bash
cd ~/code/my.saas
mv config.template.rb config.rb
```

**Step 6:** Deploy my.saas.

```bash
export RUBYLIB=~/code/my.saas
cd ~/code/my.saas/cli
ruby deploy.rb
```

Now, you can navigatoe the my.saas website from the host browser:

[http://127.0.0.1:3000/login](http://127.0.0.1:3000/login)

![Login Screen](./docu/thumbnails/login.png)

You can login using the default credentials:
- user: `su`
- password: `Testing123` 

If the website is not working, you can check the file `~/deployment.log` in the server node.

## 3. Running Scripts

Every time you want to run a Ruby script using the my.saas framework, you have to set the environment variable `RUBYLIB` properly.

```bash
export RUBYLIB=/home/blackstcack/code/my.saas
```

E.g.: This [signup example](./examples/signup.rb) registers a new account in the database.

```bash
export RUBYLIB=/home/blackstcack/code/my.saas
cd $RUBYLIB/examples
ruby signup.rb
```

Every new script must looks like below:

```ruby
# load gems and connect database
require 'mysaas'
require 'lib/stubs'
require 'config'
require 'version'
DB = BlackStack.db_connect
require 'lib/skeletons'

# create a new l
l = BlackStack::LocalLogger.new('<your-script-name-here>.log')

begin
    l.logs 'Starting the process... '
	
	# TODO: Add your code here.

    l.logf 'done'.green

# catch the case when the process is interrupted
rescue Interrupt => e
    l.logf e.message.red
    l.logf e.backtrace.join("\n")

# catch the case when an exception is raised
rescue Exception => e
    l.logf e.message.red
    l.logf e.backtrace.join("\n")

# ensure releasing of resources and the execution of any other mandatory code
ensure
    GC.start
    DB.disconnect

    # TODO: add any other mandatory code here.

    l.log 'process finished'.green
end
```

## 4. Models

The folder [sql](./sql/) contains the database schema and the seed data for running my.saas. Read the files into the folder [sql](./sql/) and get familiarized with them.

The folder [models/skeleton](./models/skeleton/) has [Sequel](https://sequel.jeremyevans.net/) defined clases to manage objects that persist in the database. 

Any **persistance class** should inherit from `Sequel::Model`.

E.g.:

```ruby
module BlackStack
  module MySaaS
    class Account < Sequel::Model(:account)

		# class attributes and method are here
	
	end 
  end
end
```

**Creating Objects:**

Use the function `guid` if you need a **Globally Unique ID** (or simply **GUID**) for creating a new persistance object.

Use the function `now` if you need the current timestamp.
The function `now` returns the current timestamp at GTM-3 (Buenos Aires date/time).

E.g.:

```ruby
# load gem and connect database
require 'mysaas'
require 'lib/stubs'
require 'config'
require 'version'
DB = BlackStack.db_connect
require 'lib/skeletons'

a = BlackStack::MySaaS::Account.new
a.id = guid
a.id_account_owner = BlackStack::MySaaS::Account.first.id
a.name = 'ACMD LLC'
a.create_time = now
a.id_timezone = BlackStack::MySaaS::Timezone.first.id
a.save
```

**Extending the Model**

You can extend the database schema with new tables and define their persistance models too.

E.g.: You would want to register surveys from new users. Follow the steps below to add a new table called `survey`

1. Create a new file `a001.sql` into the folder [sql](./sql), and write this script inside:

```sql
CREATE TABLE IF NOT EXISTS public.survey (
	id uuid NOT NULL PRIMARY KEY,
  id_user uuid NOT NULL REFERENCES "user"("id"),
  id_timezone uuid NOT NULL REFERENCES "timezone"("id"),
  job_position VARCHAR(600) NOT NULL,
  company_headcount INT NOT NULL
);
```

**Note:** Name the file `a001.sql` if this is the first file you add into the folder [sql](./sql). If this is the second file you add, it should be `a002.sql`. When you add a new file into the [sql](./sql) filder you have to increase the number of the last file added.

2. Create a new file `survey.rb` into the folder [models/skeletons/core](./models/skeleton/core), and write this script inside:

```ruby
module BlackStack
  module MySaaS
    class Survey < Sequel::Model(:survey)

		  # add custom attributes and methods here
	
	  end 
  end
end
```

3. Add a line to require the file `survey.rb` from [lib/skeletons.rb](./lib/skeletons.rb), as shown below:

```ruby
require 'models/skeleton/core/survey'
```

4. Run the migration file [a001.sql](./sql/a001.sql) and restart the webserver by running the script [deploy.rb](./cli/start.rb) script.

```bash
cd $RUBYLIB/cli
ruby deploy.rb
```


## 5. Screens

If you want to add a new screen, you have to modify the [app.rb](./app.rb) file.

E.g.: Follow the steps below to add a new "demo page" to your project.

1. add the lines below into the [app.rb](./app.rb) file:

```ruby
get '/demo' do
  "Deno Screen"
end
```

2. Restart the webserver by running the [start.rb](./cli/start.rb) script.

```bash
cd $RUBYLIB/cli
ruby start.rb
```

![Demo Screen](./docu/thumbnails/demo-screen.png)

**Using the Layout for Public Pages:**

You can embeed your HTML code into the same frame used by the [login screen](./views/login.erb) seen before.

1. Save your HTML code into a new file into the [views](./views). In this example, it would be [views/demo.erb](./views/demo.erb).

```erb
Demo Screen
```

2. Write again the entry in the [app.rb](./app.rb) file.

```ruby
get '/demo' do
  erb :'views/demo', :layout => :'/views/layouts/public'
end
```

Remember to restart the webserver by running the [start.rb](./cli/start.rb) script.

```bash
cd $RUBYLIB/cli
ruby start.rb
```

![Demo Screen with Layout of Public Page](./docu/thumbnails/demo-screen-with-layout-of-public-page.png)

**Using the Layout for Private Pages:**

The **private pages** are pages that require a login.

E.g.: Follow the steps below to a **survey screen** to show up every when a new user signup.

1. Save your HTML code into a new file into the [views](./views). In this example, it would be [views/survey.erb](./views/demo.erb).

```html
<h1>Survey Screen</h1>
```

2. Write again the entry in the [app.rb](./app.rb) file.

```ruby
get '/survey', :auth => true do
  erb :'views/survey', :layout => :'/views/layouts/core'
end
```

The `auth` condition will get the page forwarding to [login](./views/login.erb) if there are not any user logged in.

The `core` layout will embbed your HTML into a frame designed for private pages only.

Remember to restart the webserver by running the [start.rb](./cli/start.rb) script.

```bash
cd $RUBYLIB/cli
ruby start.rb
```

![Survey Screen](./docu/thumbnails/survey-screen.png)

**Navigation Bars**

**Panels**

**Forms**

**Tables**

## 6. Filters

## 7. Reactive Elements

## 8. Extensions

