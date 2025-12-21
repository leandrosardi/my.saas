## Configuration

This chapter explains how `MySaaSFile` is derived from your deployment definition, which placeholders are resolved by the secret-aware `BlackOpsFile`, and the recommended way to keep the public template and private secrets separate.

- [1. `MySaaSFile`](#1-mysaasfile)
- [2. `BlackOpsFile`](#2-blackopsfile)
- [3. Secrets Management](#3-secrets-management)
- [4. Recommended Storage Pattern](#4-recommended-storage-pattern)

### 1. `MySaaSFile`

`MySaaSFile` is a template that is rendered for you every time you run `saas deploy --node=foo`. 

E.g.: 

**MySaaSFile**
```ruby
BlackStack::PostgreSQL::set_db_params({
  :db_url => '!!postgres_url',
  :db_port => !!postgres_port,
  :db_name => '!!postgres_database',
  :db_user => '!!postgres_username',
  :db_password => '!!postgres_password',
})
```

The deployer copies the template to the node and fills the runtime values that match that node, so you do not edit the generated file by hand.

### 2. `BlackOpsFile`

Inside `MySaaSFile` you will find placeholders such as `!!postgres_password`, `!!session_secret`, and others. 

Those variables are replaced at deploy time with the actual node attributes that you define inside your `BlackOpsFile`. 

E.g.: 

**BlackOpsFile**
```ruby
# Web Server Node
#
BlackOps.add_node({
    :name => 'web',
    # ...
    :postgres_url => "foo",
    :postgres_port => "foo",
    :postgres_database => "foo",
    :postgres_username => "foo",
    :postgres_password => "foo",
    # ...
})
```

If you change a node attribute, rerun deployment so the template is regenerated with the fresh values.

```
saas deploy --node=web
```

### 3. Secrets Management

Because the variables in `MySaaSFile` are resolved from node attributes, the template file itself never contains secrets and can safely be published inside your project repository. 

Every secret, like database passwords or session secrets, must go into `BlackOpsFile` so they stay encrypted and out of source control.

### 4. Recommended Storage Pattern

- Keep `MySaaSFile` inside your public project repo so every developer can see the configuration structure. 

- Store `BlackOpsFile` inside a private repository (we call it `secret`) and grant access to a minimal number of operators. 

That way the deploy pipeline can stitch together the two files, while sensitive values remain protected.

