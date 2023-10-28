# kill all micro.data processed except postgress
ps ax | grep "code/my.saas" | grep -v postgres | grep -v grep | cut -b1-7 | xargs -t kill -9 >/dev/null 2>&1;
# start webserver
export RUBYLIB=~/code
cd ~/code/my.saas
ruby $HOME/code/code/my.saas/app.rb port=3000 config=./config.rb > /dev/null 2>&1 &
#ruby $HOME/code/code/my.saas/p/dispatcher.rb > /dev/null 2>&1 &
#ruby $HOME/code/code/my.saas/p/worker.rb > /dev/null 2>&1 &
#ruby $HOME/code/code/my.saas/extensions/i2p/p/ipn.rb > /dev/null 2>&1 &
#ruby $HOME/code/code/my.saas/extensions/i2p/p/baddebt.rb > /dev/null 2>&1 & # ==> Test this process before put it on production.
#ruby $HOME/code/code/my.saas/extensions/i2p/p/expire.rb > /dev/null 2>&1 & # ==> Test this process before put it on production.
