## User Data Deletion

BlackStack keeps an account's footprint in the database for a few days after the user requests deletion, then a dedicated drainer job walks across every configured table and removes the remaining rows and foreign keys. The drainer can also delete stale accounts automatically through `:account_auto_delete`, so it keeps storage lean without manual intervention.

### 1. Getting started

1. Tune the global retention window in your `MySaaSFile` (or another initializer) so that `:days_to_keep` matches how long you must keep deleted records:

```ruby
BlackStack::Drainer.set(
	days_to_keep: 30 # keep a recovery window before hard deleting
)
```

2. Register the tables you need to clear with `:steps`.

```ruby
BlackStack::Drainer.add_steps([
	{ table: :movement, action: :delete },
	{ table: :invoice, action: :delete },
	{ table: :subscription, action: :delete }
])
```

3. Start the drainer script (`p/drainer.rb`) or a scheduler so the loop in `BlackStack::Drainer.run` enforces the policy and prunes data once the retention window expires.

```
cd /home/mysaas/code1/my.saas/p
export RUBYLIB=/home/mysaas/code1/my.saas
ruby notifier.rb
```

### 2. Custom DataSet Functions

Complex joins can be handled with `:dataset_function` just like the `invoice_item` step shown here:

```ruby
BlackStack::Drainer.add_steps([
	{
		table: :invoice_item,
		action: :delete,
		dataset_function: lambda { |id_account|
			DB[:invoice_item]
				.join(:invoice, id: :id_invoice)
				.where(Sequel[:invoice][:id_account] => id_account)
		}
	},
])
```

### 3. Unlink Records

When a table owns foreign keys to other rows, you may need to drop those references before deleting the parent. 

The drainer supports `:action => :unlink` with a `:key` so it can nullify the column. 

For example, the `:trigger` steps below remove references from the `id_source` column first and then delete the orphaned rows:

```ruby
BlackStack::Drainer.add_steps([
  { table: :trigger, action: :unlink, key: :id_source },
  { table: :trigger, action: :unlink, key: :id_action },
  { table: :trigger, action: :unlink, key: :id_rule },
  { table: :trigger, action: :unlink, key: :id_link },
])
```

### 4. Batch Size

Each delete/unlink loop pulls up to `:batch_size` rows before issuing the destructive SQL, so setting it smaller keeps transactions lightweight during draining and larger values improve throughput once you trust the performance.

```ruby
BlackStack::Drainer.set(
	batch_size: 200 # process two hundred rows per iteration for safer draining
)
```

### 5. Accounts Auto-Deletion

The `:account_auto_delete` lambda is invoked before the draining loop to flag idle accounts for removal. 

By default, it selects accounts with no logins or transactions within the last `days` window and marks them as `delete_time` candidates so they eventually reach the draining retention threshold.

```ruby
BlackStack::Drainer.set(
	account_auto_delete: lambda { |limit:, days:|
		DB[:account]
			.where(delete_time: nil)
			.where(Sequel.lit("last_login < NOW() - INTERVAL '#{days} days'"))
			.limit(limit)
			.select_map(:id)
	}
)
```

