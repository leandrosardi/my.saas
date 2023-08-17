# This examples shows how to iterate all signatures from postmark, searching for a specific email address.

require 'postmark'

# API access to PostMark
POSTMARK_API_TOKEN = '1499e037-91e9-4f03-b563-*********'

# create client
client_postmark = Postmark::AccountApiClient.new(POSTMARK_API_TOKEN, secure: true, http_ssl_version: :TLSv1_2)

sender_email = 'support@connectionsphere.com'
signs = client_postmark.get_signatures
pagesize = 30 # TODO: increase this value to 300 for optimization
i = 0
j = 1
sign = nil
while j>0 && sign.nil?
    buff = client_postmark.get_signatures(offset: i, count: pagesize)
    j = buff.size
    i += pagesize
    sign = buff.select { |s| s[:email_address]==sender_email }.first
end # while

id = sign[:id] if !sign.nil?

puts id
