# kill all micro.data processed except postgress
ps ax | grep "puma" | grep -v postgres | grep -v grep | cut -b1-7 | xargs -t kill -9
#ps ax | grep "sync.rb" | grep -v postgres | grep -v grep | cut -b1-7 | xargs -t kill -9
#ps ax | grep "ipn.rb" | grep -v postgres | grep -v grep | cut -b1-7 | xargs -t kill -9
#ps ax | grep "baddebt.rb" | grep -v postgres | grep -v grep | cut -b1-7 | xargs -t kill -9
#ps ax | grep "expire.rb" | grep -v postgres | grep -v grep | cut -b1-7 | xargs -t kill -9