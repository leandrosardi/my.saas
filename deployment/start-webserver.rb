# setup deploying rutines
BlackStack::Deployer::add_routine({
  :name => 'start-webserver',
  :commands => [{
    :command => :'stop-webserver',
  }, {
    :command => '
      # kill all micro.data processed except postgress
      ps ax | grep "freeleadsdata" | grep "puma" | grep -v postgres | grep -v grep | cut -b1-7 | xargs -t kill -9 >/dev/null 2>&1;    
      # start webserver
      cd ~/code/freeleadsdata/app
      ruby app.rb port=3000 config=./config.rb > /dev/null 2>&1 &
    ',
  }],
});