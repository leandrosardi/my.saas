Store your deployment routines here.

**Example:**

```ruby
# setup deploying rutines
BlackStack::Deployer::add_routine({
  :name => 'install-webserver',
  :commands => [{
    :command => '
      # create code folder
      mkdir -p ~/code >>~/freeleadsdata.app.output 2>&1
      mkdir -p ~/code/freeleadsdata >>~/freeleadsdata.app.output 2>&1

      # clone the project
      git clone https://%git_username%:%git_password%@github.com/freeleadsdata/app ~/code/freeleadsdata/app >>~/freeleadsdata.app.output 2>&1
      git clone https://%git_username%:%git_password%@github.com/freeleadsdata/model ~/code/freeleadsdata/model >>~/freeleadsdata.app.output 2>&1

        ...
    ',
  }],
});
```