## SandBox Flag

`BlackStack.sandbox?` returns `true` whenever a `.sandbox` file sits in the current working directory of the Ruby process.

```ruby
if BlackStack.sandbox?
	warn 'sandbox mode'
end
```

- [1. Creating the Flag](#1-creating-the-flag)
- [2. Checking `.sandbox` in `MySaaSFile`](#2-checking-sandbox-in-mysaasfile)
- [3. Checking `.sandbox` to Enable BreackPoints](#3-checking-sandbox-to-enable-breackpoints)

### 1. Creating the Flag

Put the empty `.sandbox` file into the folder that actually runs your process so the working directory

```
touch .sandbox
```

- For example: If the `mysaas_app.service` owns `/home/code1/my.saas`, create the flag there so every `systemctl restart` and related process sees it.

```
touch /home/code1/my.saas/.sandbox
```

- If you prefer to run a Ruby script manually from `p/`, move the flag down to that folder so a bare `ruby notifier.rb` inherits the sandbox context too,

```
cd /home/mysaas/code1/my.saas/p
touch .sandbox
```

and then run `notifier.rb` manually.

```
export RUBYLIB=/home/mysaas/code1/my.saas
ruby notifier.rb
```

### 2. Checking `.sandbox` in `MySaaSFile`

The `.sandbox` file is widely used into `MySaaSFile` to switch configurations in different environments.

- For example: The very first constants in `MySaaSFile` gate whether you serve `127.0.0.1` internally or emit production domains by checking `BlackStack.sandbox?` on `APP_DOMAIN`, `COMPANY_URL`, and each `CS_HOME_PAGE_*` value so local requests never leak live URLs.

```ruby
APP_DOMAIN = BlackStack.sandbox? ? '127.0.0.1' : '!!domain'
CS_HOME_PAGE_PROTOCOL = BlackStack.sandbox? ? 'http' : 'https'
```

### 3. Checking `.sandbox` to Enable BreackPoints

Find this piece of code in `MySaaSFile`:

```ruby
BlackStack::Debugging::set({
	:allow_breakpoints => BlackStack.sandbox?,
})
```

that will enable or disable the calls to `binding.pry`.
