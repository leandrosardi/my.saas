# This examples shows how to iterate all signatures from postmark, searching for a specific email address.

require 'postmark'

# API access to PostMark
POSTMARK_API_TOKEN = '1499e037-91e9-4f03-b563-************'

# create client
client_postmark = Postmark::AccountApiClient.new(POSTMARK_API_TOKEN, secure: true, http_ssl_version: :TLSv1_2)

id = '4217384'

s = client_postmark.get_sender(id)

puts s[:confirmed]
puts s[:name]
puts s[:email_address]
