# setup deploying rutines
BlackStack::Deployer::add_routine({
  :name => 'stop-mysaas',
    :commands => [
      { :command => "cd /home/%ssh_username%/code/mysaas/cli; ruby stop.rb;", :sudo => false, },
  ],
});