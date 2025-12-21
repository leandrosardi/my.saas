## Installation

Follow the steps below on a **fresh** installation of **Ubuntu 22.04**.

- [1. Install the `saas` command](#1-install-the-saas-command)
- [2. Download the `BlackOpsFile`](#2-download-the-blackopsfile)
- [3. Download Required Operations](#3-download-required-operations)
- [4. Setup the Enrivonmnet Variable `MYSAAS_ROOT_PASSWORD`](#4-setup-the-enrivonmnet-variable-mysaas_root_password)
- [5. Install the Environment](#5-install-the-environment)
- [6. Start My.SaaS Service](#6-start-mysaas-service)
- [7. Login to My.SaaS](#7-login-to-mysaas)
- [8. Stop My.SaaS Service](#8-stop-mysaas-service)


### 1. Install the `saas` command

You need to [install the BlackOps's `saas` commnad](https://github.com/leandrosardi/blackops?tab=readme-ov-file#install-the-saas-command) in your local environment.

```
wget https://github.com/leandrosardi/blackops/raw/refs/heads/main/bin/saas--ubuntu-22.04
sudo mv ./saas--ubuntu-22.04 /usr/bin/saas
sudo chmod 777 /usr/bin/saas
```

### 2. Download the `BlackOpsFile`

This is a basic configuration for installing a local environment.

If you want to know more about `BlackOpsFile`, refer to [this tutorial](https://github.com/leandrosardi/blackops?tab=readme-ov-file#3-configuration-files).

```
cd ~ && \
wget https://raw.githubusercontent.com/leandrosardi/my.saas/refs/heads/main/BlackOpsFile
```

### 3. Download Required Operations

Some `.op` files are required to install **My.SaaS** using [BlackOps](https://github.com/leandrosardi/blackops).

```
cd ~ && \
wget https://raw.githubusercontent.com/leandrosardi/blackops/refs/heads/main/ops/hostname.op && \
wget https://raw.githubusercontent.com/leandrosardi/blackops/refs/heads/main/ops/mysaas.install.ubuntu_22_04.base.op && \
wget https://raw.githubusercontent.com/leandrosardi/blackops/refs/heads/main/ops/mysaas.install.ubuntu_22_04.postgresql.op && \
wget https://raw.githubusercontent.com/leandrosardi/blackops/refs/heads/main/ops/mysaas.install.ubuntu_22_04.service.op && \
wget https://raw.githubusercontent.com/leandrosardi/blackops/refs/heads/main/ops/mysaas.deploy.base.op && \
wget https://raw.githubusercontent.com/leandrosardi/blackops/refs/heads/main/ops/mysaas.start.op && \
wget https://raw.githubusercontent.com/leandrosardi/blackops/refs/heads/main/ops/mysaas.stop.op
```

### 4. Setup the Enrivonmnet Variable `MYSAAS_ROOT_PASSWORD`

```
export MYSAAS_ROOT_PASSWORD=<root password of your local computer>
```

### 5. Install the Environment

The line below will install 2 nodes, **web server** (`web`) and **database server** (`db`) in your local computer.

In a production environment, `web` and `db` are hosted in different servers because of a security reasons.

```
saas install --config=./BlackOpsFile --node=* --root && \
saas deploy --config=./BlackOpsFile --node=web && \
saas migrations --config=./BlackOpsFile --node=web
```

### 6. Start My.SaaS Service

```
saas start --config=./BlackOpsFile --node=web --root
```

### 7. Login to My.SaaS

1. Visit [http://127.0.0.1:3000](http://127.0.0.1:3000).
2. Access with default credentials:

    - username: `su`
    - password: `su`

### 8. Stop My.SaaS Service

```
saas stop --config=./BlackOpsFile --node=web --root
```

