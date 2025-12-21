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

