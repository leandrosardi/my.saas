# setup deploying rutines
BlackStack::Deployer::add_routine({
  :name => 'start-mysaas',
    :commands => [
      { :command => "cd /home/%ssh_username%/code/mysaas/cli; ruby start.rb;", :sudo => false, },
  ],
});
