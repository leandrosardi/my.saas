## Installation

MySaaS is currently supporting **Ubuntu 20.04** and **Ubuntu 22.04**.

### 1. Install the `saas` command

You need to [install the BlackOps's `saas` commnad](https://github.com/leandrosardi/blackops?tab=readme-ov-file#install-the-saas-command) in your local environment.

### 2. Download Required Operation Scripts

Some `.op` files are required to install **My.SaaS** using [BlackOps](https://github.com/leandrosardi/blackops).

```
cd ~ && \
wget https://raw.githubusercontent.com/leandrosardi/blackops/refs/heads/main/ops/hostname.op && \
wget https://raw.githubusercontent.com/leandrosardi/blackops/refs/heads/main/ops/mysaas.install.ubuntu_22_04.base.op && \
wget https://raw.githubusercontent.com/leandrosardi/blackops/refs/heads/main/ops/mysaas.install.ubuntu_22_04.postgresql.op
```

### 3. Setup the Enrivonmnet Variable `OPSROOTPASS`

```
export OPSROOTPASS=<root password of your local computer>
```

### 4. Install the Environment

```
saas install --config=./BlackOpsFile --node=local --root
```

### 4. Deploy the Software

_pending instructions to deploy both, source code and migrations_

### 5. Starting My.SaaS Service

_pending_

### 6. Stopping My.SaaS Service

_pending_
