# this script is for map all signatures from postmark to the table `postmark_signature`.

# load gem and connect database
require 'mysaas'
require 'lib/stubs'
require 'config'
require 'version'
DB = BlackStack::CRDB::connect
require 'lib/skeletons'

l = BlackStack::LocalLogger.new('./update_signatures.log')

# API access to PostMark
POSTMARK_API_TOKEN = '1499e037-91e9-4f03-b563-********'

# create client
l.logs 'create client... '
client_postmark = Postmark::AccountApiClient.new(POSTMARK_API_TOKEN, secure: true, http_ssl_version: :TLSv1_2)
l.done

signs = client_postmark.get_signatures
pagesize = 30 # TODO: increase this value to 300 for optimization
i = 0
j = 1
sign = nil
while j>0 && sign.nil?
    buff = client_postmark.get_signatures(offset: i, count: pagesize)
    j = buff.size
    i += pagesize
    # iterate buffer
    buff.each { |sign|
        h = JSON.parse(sign.to_json)
        l.logs "#{h['id']}... "
        o = BlackStack::MySaaS::PostmarkSignature.where(:postmark_id => h[:id]).first
        if o.nil?
            o = BlackStack::MySaaS::PostmarkSignature.new 
            o.id = guid
        end
        o.postmark_id = h['id']
        o.name = h['name']
        o.email = h['email_address']
        o.email_verified = h['confirmed']
        o.save
        l.done
    } # each
end # while
