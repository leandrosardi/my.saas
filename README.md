
## IMPORTANT: THIS FRAMEWORK IS STILL UNDER DEVELOPMENT


---


![GitHub issues](https://img.shields.io/github/issues/leandrosardi/my.saas) ![GitHub](https://img.shields.io/github/license/leandrosardi/my.saas) ![GitHub tag (latest by date)](https://img.shields.io/github/v/tag/leandrosardi/my.saas) ![GitHub last commit](https://img.shields.io/github/last-commit/leandrosardi/my.saas)

![logo](./public/core/images/logo.png)

# MySaaS - Open Source SaaS Platform - Extensible and Scalable.  

**MySaaS** is an open-source, extensible and scalable platform for develop your own Software as a Service (SaaS), e-Commerce, Education Platform, Social Network, Forum or any kind of memberships based product.

![Example of What Can You Create with My.SaaS](./docu/thumbnails/dashboard.png)

## Getting Started

1. On Ubuntu 20.04, download the script for installing our **standard environment**:

```
wget https://raw.githubusercontent.com/leandrosardi/environment/main/sh/install.ubuntu.20_04.sh
```

2. Install **my.saas**:

Switch to `root` and run this command:

```
bash install.ubuntu.20_04.sh <hostname> <password>
```

- A new user `blackstack` will be added to your operative system, with the password provided in the command line.

- The `hostname` of your computer will be changed too.

3. Switch user to `blackstack`.

4. Install and run your first SaaS:

```
saas deploy ssh=blackstack@<password>@localhost:22
```

The following (and very simple architecture) has been installed in your computer:

_(image)_

5. Visit your SaaS at [http://127.0.0.1:3000](http://127.0.0.1:3000).


Recommended readings:

- [References Architectures](/docu/00.reference-architectures.md).

- [Command Line Interface](/docu/00.command-line-interface.md).




------------------------------------------------------------------------

**Outline:**

Getting Started

1. [Features](#1-features)
2. [Getting Started](#2-getting-started)
3. [Running Scripts](#3-running-scripts)
4. [Extensions](#4-extensions)

Models

5. [Persistence Classes](#5-persistence-classes)
6. [Creating Objects](#6-creating-objects)
x. Core Model _(review of the persistance classes)_
x. Helper Functions _(review most frequently used blackstack core functions)_

Screens

7. [Screens](#7-screens)
8. [Filters](#8-filers)
9. [Access Points](#9-access-points)
10. [Reactive Elements](#10-reactive-elements)
11. [Charts](#11-charts)

Back-End Processing

12. [Stand Alone Processes](#12-stand-alone-processes)
13. [Distributed Processes](#13-distributed-processes)
14. [Adding Javascript Libraries](#14-adding-javascript-libraries)
15. [Adding Stylesheet Libraries](#15-adding-stylesheet-libraries)
16. [Adding Images](#16-adding-images)

Configurations

17. Setting Logo
18. Setting Left Bar
19. Setting Footer _(config.rb, and extension is deprecated)_
20. Adding Extensions _(config.rb, customizing extension settings, and extension dependencies)_
21. Funnel _(ga, captchas, screens workflow)_
22. Super-User
23. Elastic Storage
24. Sandbox Mode
25. Debugging
26. Transactional Emails

Deploying

27. Versioning _(config.rb, and extension)_
28. Secret Files
29. Deployment

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

## 4. Extensions

If you want to add screens to My.SaaS, you shouldn't for the [my.saas repository](https://github.com/leandrosardi/my.saas), because each time [@leandrosardi](https://github.com/leandrosardi) releases a new version of my.saas you should have to merge such a new version with your fork.

To to disengage the my.saas core from your project, my.saas provide a feature called **[extensions](https://github.com/leandrosardi/mysaas-extension-template)**.

Follow these steps to create your own **extension**:

**Step 1:** Fork the [my.saas extensions template](https://github.com/leandrosardi/mysaas-extension-template), as a new repository in your GitHub organization.

E.g.: Your extension may be called **my.extension**.

**Step 2:** Pull your new repository in your local computer.

E.g.: If the name of your organization is **acme** and the name of your extension is **my.extension**, you should execute the following commands:

```bash
cd $HOME/code/my.saas/extensions
git clone https://github.com/acme/my.extension
```

and you will find the source code of your extension in the folder `$HOME/code/my.saas/extensions/my.extension`.

**Step 3:** Edit the **merge-tags** in the source code of your extension.

E.g.: If the name of your organization is **acme** and the name of your extension is **my.extension**, you should replace the following merge-tags in the source code into the folder `$HOME/code/my.saas/extensions/my.extension`:

| merge-tag                                    | replacement value                            |
|----------------------------------------------|----------------------------------------------|
| <!your-github-username!>                     | acme                                         |
| <!your-github-repo-name-for-this-extension!> | my.extension                                 |
| <!extension-description-here!>               | Example exension to become a My.SaaS expert. |

**Step 4:** Rename the folder `<!your-github-repo-name-for-this-extension!>`.

E.g.: If the name of your extension is **my.extension**, you should run the following command:

```bash
mv $HOME/code/my.saas/extensions/my.extension/public/<!your-github-repo-name-for-this-extension!> $HOME/code/my.saas/extensions/my.extension/public/my.extension
```

## 5. Persistence Classes

The folder [sql](./sql/) contains the database schema and the seed data for running my.saas. Read the files into the folder [sql](./sql/) and get familiarized with them.

The folder [models/skeleton](./models/skeleton/) has [Sequel](https://sequel.jeremyevans.net/) defined clases to manage objects that persist in the database. These classes are called **persistence classes**.

Here are the guidelines for writing **persistence classes**:

**Guideline 1.** Each **persistence class** must be placed in one different `.rb` file.

E.g.: You create the file [models/skeleton/account.rb](./models/skeleton/account.rb) to place the code of the **persistence class** for the table **account**.

**Guideline 2.** Each file added to the folder [models/skeleton](./models/skeleton/), must be required from the file [lib/skeletons.rb]. Such a `require` must looks like follows:

```ruby
require "/extensions/<name of the project module>/models/skeleton/<name of the file with a persistence class>"
```

E.g.:

```ruby
require "/extensions/<name of the project module>/models/skeleton/account.rb"
```

**Note:** If you don't know the name of the **project module**, ask it to [@leandrosardi](https://github.com/leandrosardi).

**Guideline 3.** Any **persistence class** should inherit from `Sequel::Model`.

E.g.: In the file [models/skeleton/account.rb](./models/skeleton/account.rb) you write a Ruby code like this:

```ruby
class Account < Sequel::Model(:account)

	# class attributes and method are here
	
end # class Account 
```

**Guideline 4.** Any **persistence class** must be contained into the **project module** that you are working on (e.g.: `my.extension`). 

If you don't know the name of the **project module**, ask it to [@leandrosardi](https://github.com/leandrosardi).

E.g.: In the file [models/skeleton/account.rb](./models/skeleton/account.rb) you write a Ruby code like this:

```ruby
module <name of the project module>
  class Account < Sequel::Model(:account)

	# class attributes and method are here
	
  end # class Account
end # module <name of the project module>
```

**Guideline 5.** The **project module** must be contained into the `BlackStack` module too.

E.g.: In the file [models/skeleton/account.rb](./models/skeleton/account.rb) you write a Ruby code like this:

```ruby
module BlackStack
  module <name of the project module>
    class Account < Sequel::Model(:account)

		# class attributes and method are here
	
	end # class Account
  end # module <name of the project module>
end # module BlackStack
```

**Guideline 6.** Any **persistence class** must have an array attribute for each other **persistence class** who has a foreing key to it.

E.g.: In the file [models/skeleton/account.rb](./models/skeleton/account.rb) you write a Ruby code like this:

```ruby
module BlackStack
  module <name of the project module>
    class Account < Sequel::Model(:account)
        # array attribute for each other **persistence class** who has a foreing key to it.
        one_to_many :users, :class=>:'BlackStack::MySaaS::User', :key=>:id_account
	
	end # class Account
  end # module <name of the project module>
end # module BlackStack
```

**Guideline 7.** Any **persistence class** must have an attribute for each other **persistence class** that it has a foreing key to.

E.g.: In the file [models/skeleton/account.rb](./models/skeleton/account.rb) you write a Ruby code like this:

```ruby
module BlackStack
  module <name of the project module>
    class Account < Sequel::Model(:account)
        # array attribute for each other **persistence class** who has a foreing key to it.
        one_to_many :users, :class=>:'BlackStack::MySaaS::User', :key=>:id_account

        # attribute for each other **persistence class** that it has a foreing key to.
        many_to_one :timezone, :class=>:'BlackStack::MySaaS::Timezone', :key=>:id_timezone
	
	end # class Account
  end # module <name of the project module>
end # module BlackStack
```

**Guideline 8.** Some AI assistants use to add `blackstack_db` as a plugin of the sequel classes. That is not correct.

E.g.: The class below has a line `plugin :blackstack_db`. That is not necessary.

```ruby
module BlackStack
  module <name of the project module>
    class Account < Sequel::Model(:account)
        plugin :blackstack_db

        # array attribute for each other **persistence class** who has a foreing key to it.
        one_to_many :users, :class=>:'BlackStack::MySaaS::User', :key=>:id_account

        # attribute for each other **persistence class** that it has a foreing key to.
        many_to_one :timezone, :class=>:'BlackStack::MySaaS::Timezone', :key=>:id_timezone
	
	end # class Account
  end # module <name of the project module>
end # module BlackStack
```

## 6. Creating Objects

Use the function `guid` if you need a **Globally Unique ID** (or simply **GUID**) for creating a new persistence object.

Use the function `now` if you need the current timestamp.
The function `now` returns the current timestamp at GTM-3 (Buenos Aires date/time).

E.g.: The script below will register a new account in the database.

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
a.name = 'ACME LLC'
a.create_time = now
a.id_timezone = BlackStack::MySaaS::Timezone.first.id
a.save
```

## 7. Screens

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

### 7.1. Layout of Public Pages

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

### 7.2. Layout of Private Pages

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

### 7.3. Navigation Bars

Add the code below at the top if the [/views/survey.erb](./views/survey.erb) screen, to add a 2-level navigation bar to your page.

```html
<div class="mynavbar2 mysticky">
    <div class="row-fluid">	
        <div class="span3">
            <%=nav1("Survey")%>
        </div>
    </div>
</div>
```

In your survey page, a 2-level navigation bar will look like this:

```
ACME LLC > Survey
```

where `ACME LLC` is the the value in the field `name` of the record in the `account` table, to which the logged in user is beloning to.

![Survey with Navigation Bar](./docu/thumbnails/survey-with-navigation-bar.png)

### 7.4. Top Buttons

Inside the `.mynavbar2` div, you can add a second child div to place buttons.

E.g.: The code below adds one blue button to submit the survey, and one gray button to skip the survey.

```html
<div class="mynavbar2 mysticky">
    <div class="row-fluid">	
        <div class="span3">
            <%=nav1("Survey")%>
        </div>
    </div>

    <div class="span9">
      <button class='btn btn-blue'>Submit</button>
      <a class='btn btn-gray' href='./'>Skip</a>
    </div>
</div>
```

**Note:** The second button is really a link to the dashboard.

![Survey with Top Buttons](./docu/thumbnails/survey-top-buttons.png)

### 7.5. ToolTips

Buttons may have nice tooltips too.

E.g.: The code below includes a tooltip to the submit button:

```html
<div class="mynavbar2 mysticky">
    <div class="row-fluid">	
        <div class="span3">
            <%=nav1("Survey")%>
        </div>
    </div>

    <div class="span9">
      <button class='btn btn-blue' title="Click here after you have filled all the fields of the survey.">Submit</button>
      <a class='btn btn-gray' href='./'>Skip</a>
    </div>
</div>
```

![Survey with Top Buttons](./docu/thumbnails/survey-top-buttons-with-tooltip.png)

### 7.6. Input Boxes

You can add inputs too. 

E.g.: The code below includes an input box and a button to perform searches.

```html
<div class="mynavbar2 mysticky">
    <div class="row-fluid">	
        <div class="span3">
            <%=nav1("Survey")%>
        </div>
    </div>

    <div class="span9">
      <button class='btn btn-blue' title="Click here after you have filled all the fields of the survey.">Submit</button>
      <a class='btn btn-gray' href='./'>Skip</a>

      <input class="input input-large" id="q" name="q" value="">
      <button class="btn btn-blue" id="search"><i class="icon-search"></i></button>
    </div>
</div>
```

![Surve with Top Buttons with Input Box](./docu/thumbnails/survey-top-bar-with-input-box.png)

### 7.7. Dropdown Menus

In the same div where you placed buttons you can also add dropdown menus.

E.g.: The code below adds a list of tasks to perform by the user, in order to help the user to operate the software.

```html
<div class="mynavbar2 mysticky">
    <div class="row-fluid">	
        <div class="span3">
            <%=nav1("Survey")%>
        </div>

        <div class="span9">
            <button class='btn btn-blue'>Submit</button>
            <a class='btn btn-gray' href='./'>Skip</a>

            <div class="btn-group" style="vertical-align:top;">  
                <a id="tasks_list" name="tasks_list" class="btn dropdown-toggle" data-toggle="dropdown" href="#">
                    <b>Pending Tasks:</b> Complete the Survey <i class="icon-circle" style="color:gray;"></i> <span class="caret"></span>
                </a>
                <ul class="dropdown-menu">
                    <li>
                        <button class="btn btn-link" disabled=""><i class='icon-ok'></i> Signup</button>
                    </li>
                    <li>
                        <button class="btn btn-link" href='/survey'><i class='icon-time'></i> Complete the Survey</i></button>
                    </li>
                    <li>
                        <button class="btn btn-link" href='/settings/account'><i class='icon-time'></i> Setup Your TimeZone</i></button>
                    </li>                    
                </ul>
            </div>
        </div>
    </div>
</div>
```

**Note:** The first task in the list (signup) is already performed. The other 2 tasks are pending and include the `href` to there page where such a task should be performed.

![Survey with Dropdown Menu](./docu/thumbnails/survey-with-dropdown-menu.png)

### 7.8. Panels

Below the `.mynavbar2` div you would want to place forms, tables, charts, etc.

You may want to split the screen horizontally.

E.g.: You may want to place a table in the left panel, and show other stats in the right panel.

![panels example](./docu/thumbnails/panels.png)

E.g.: In the survey screen, you a left panel to show a list of users who submited the survey, and a right panel to place the survey form.

```html
<!-- NavBar -->
<div class="mynavbar2 mysticky">
    <div class="row-fluid">	
        <div class="span3">
            <%=nav1("Survey")%>
        </div>

        <div class="span9">
            <button class='btn btn-blue' title="Click here after you have filled all the fields of the survey.">Submit</button>
            <a class='btn btn-gray' href='./'>Skip</a>
        </div>
    </div>
</div>


<section class="row-fluid box">
    <h1>Survey Screen</h1>
    
    <p>Complete this survey to help us to setup your account in a way that fir your needs perfectly!</p>

    <div class='span12'>
        <div class='span6'>
            <h3>Who Completed the Survey?</h3>
            <!-- TODO: Place the list of users beloinig this account here -->
        </div>

        <div class='span6'>
            <h3>Survey</h3>
            <!-- TODO: Place the survey form here -->
        </div>
    </div>
</section>
```

![Survey with 2 Panels](./docu/thumbnails/panels-2.png)

### 7.9. Forms

_(pending)_

### 7.10. Tables

_(pending)_

### 7.11. Fixed fields

_(pending)_

## 8. Filters

_(pending)_

## 9. Access Points

_(pending)_

## 10. Reactive Elements

_(pending)_

## 11. Charts

_(pending)_

## 12. Stand Alone Processes

_(pending)_

## 13. Distributed Processes

_(pending)_

## 14. Adding Javascript Libraries

_(pending)_

## 15. Adding Stylesheet Libraries

_(pending)_

## 16. Adding Images

_(pending)_

