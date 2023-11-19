# kill all micro.data processed except postgress
ps ax | grep "puma" | grep -v postgres | grep -v grep | cut -b1-7 | xargs -t kill -9
#ps ax | grep "actions.rb" | grep -v postgres | grep -v grep | cut -b1-7 | xargs -t kill -9
ps ax | grep "deletion.rb" | grep -v postgres | grep -v grep | cut -b1-7 | xargs -t kill -9
ps ax | grep "delivery.rb" | grep -v postgres | grep -v grep | cut -b1-7 | xargs -t kill -9
ps ax | grep "export.rb" | grep -v postgres | grep -v grep | cut -b1-7 | xargs -t kill -9
ps ax | grep "leads.upload.import.rb" | grep -v postgres | grep -v grep | cut -b1-7 | xargs -t kill -9
ps ax | grep "leads.upload.ingest.rb" | grep -v postgres | grep -v grep | cut -b1-7 | xargs -t kill -9
ps ax | grep "planner.rb" | grep -v postgres | grep -v grep | cut -b1-7 | xargs -t kill -9
ps ax | grep "timeline.rb" | grep -v postgres | grep -v grep | cut -b1-7 | xargs -t kill -9
#ps ax | grep "receive.rb" | grep -v postgres | grep -v grep | cut -b1-7 | xargs -t kill -9
ps ax | grep "ipn.rb" | grep -v postgres | grep -v grep | cut -b1-7 | xargs -t kill -9
ps ax | grep "baddebt.rb" | grep -v postgres | grep -v grep | cut -b1-7 | xargs -t kill -9
ps ax | grep "expire.rb" | grep -v postgres | grep -v grep | cut -b1-7 | xargs -t kill -9