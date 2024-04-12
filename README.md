![GitHub issues](https://img.shields.io/github/issues/leandrosardi/my.saas) ![GitHub](https://img.shields.io/github/license/leandrosardi/my.saas) ![GitHub tag (latest by date)](https://img.shields.io/github/v/tag/leandrosardi/my.saas) ![GitHub last commit](https://img.shields.io/github/last-commit/leandrosardi/my.saas)

![logo](./public/core/images/logo.png)

# MySaaS - Open Source SaaS Platform - Extensible and Scalable.  

**MySaaS** is an open-source, extensible and scalable platform for develop your own Software as a Service (SaaS), e-Commerce, Education Platform, Social Network, Forum or any kind of memberships based product.

![Example of What Can You Create with My.SaaS](./docu/thumbnails/dashboard.png)

**Outline:**

1. [Features](#1-features).
2. [Getting Started](#2-getting-started).
3. [Documentation](#3-documentation).

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

**Step 1:** Run the **Environment Installation Script**:

Download our Environment Installation Script (or simply EIS) by running the lines below:

```
cd ~
wget https://raw.githubusercontent.com/leandrosardi/environment/main/sh/install.ubuntu.20_04.sh
```

and the EIS by running the line below:

```
bash install.ubuntu.20_04.sh <hostname> <password>
```

replacing 

1. `<hostname>` with the name you have to assisng the the node where my.saas will run; and
2. `<password>` with the password you want for a new Linux user called `blackstack` who will be created by the EIS.

**Note:** For running this example, use the values `dev2` and `blackstack123`.

```
bash install.ubuntu.20_04.sh dev2 blackstack123
```

**Note:** Refer to [this other repository](https://github.com/leandrosardi/environment) for more information about the Environment Installation Script.

**Step 2:** Switch to the new `blackstack` user.

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

[http://127.0.0.1:3000](http://127.0.0.1:3000)


## 3. Documentation

01. [Installation](./docu/01.Installation.md)
02. [Configurations](./docu/02.configurations.md)
03. [Secret Files Management](./docu/03.secret-files-management.md)
04. [Deployment](./docu/04.deployment.md) 
05. [Transactional Emails](./docu/05.transactional-emails.md) 
06. Screens Development
07. Invoicing and Payments Processing
08. System Owner
09. Accounts Management
10. User Storage
11. Access Points Publishing
12. Single-Thread Backend Processing
13. Multi-Thread Backend Processing
14. Extensibility
15. Available Extensions
16. Available UI Components
17. Security
18. Archivlement

## Further Work

01. Complete documentation for all features as of version 1.5.6.
02. affiliates tracking, for managing resellers and pay commission;
03. domain aliasing, for licencing your site to other companies;
04. abuse preventing, by tracking user's network and browser fingertings;
05. shadow profiling [[1](https://en.wikipedia.org/wiki/Shadow_profile)], for sales optimizations and client retention;
06. Affiliates Tracking Extension
07. White-Labeling Features
08. Custom Alerts
09. Screens As a Code
10. Improve Funnel Configuration
	- add descriptor about the email marketing automation
	- add descriptor about which transactional emails activate for this funnel
	- add A/B testing of screens (landing, offer, plans, etc)
