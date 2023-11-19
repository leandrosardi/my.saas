# kill all micro.data processed except postgress
ps ax | grep "code/app" | grep -v postgres | grep -v grep | cut -b1-7 | xargs -t kill -9 >/dev/null 2>&1;
# start webserver
export RUBYLIB=~/code
cd ~/code/app
ruby $HOME/code/code/app/app.rb port=3000 config=./config.rb >>~/connectionsphere.app.output 2>&1 &
#ruby $HOME/code/code/app/p/actions.rb >>~/connectionsphere.app.output 2>&1 &
ruby $HOME/code/code/app/p/deletion.rb >>~/connectionsphere.app.output 2>&1 &
ruby $HOME/code/code/app/p/delivery.rb >>~/connectionsphere.app.output 2>&1 &
ruby $HOME/code/code/app/p/export.rb >>~/connectionsphere.app.output 2>&1 &
ruby $HOME/code/code/app/p/leads.upload.import.rb >>~/connectionsphere.app.output 2>&1 &
ruby $HOME/code/code/app/p/leads.upload.ingest.rb >>~/connectionsphere.app.output 2>&1 &
ruby $HOME/code/code/app/p/planner.rb >>~/connectionsphere.app.output 2>&1 &
ruby $HOME/code/code/app/p/timeline.rb >>~/connectionsphere.app.output 2>&1 &
#ruby $HOME/code/code/app/p/receive.rb >>~/connectionsphere.app.output 2>&1 &
ruby $HOME/code/code/app/extensions/i2p/p/ipn.rb >>~/connectionsphere.app.output 2>&1 & # ==> Test this process before put it on production.
#ruby $HOME/code/code/app/extensions/i2p/p/baddebt.rb >>~/connectionsphere.app.output 2>&1 & # ==> Test this process before put it on production.
#ruby $HOME/code/code/app/extensions/i2p/p/expire.rb >>~/connectionsphere.app.output 2>&1 & # ==> Test this process before put it on production.
