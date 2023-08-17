# This example shows how to add a new signature to PostMark, and get its id.

require 'postmark'

# API access to PostMark
POSTMARK_API_TOKEN = '1499e037-91e9-4f03-b563-*********'

# create client
client_postmark = Postmark::AccountApiClient.new(POSTMARK_API_TOKEN, secure: true, http_ssl_version: :TLSv1_2)

# create sender
begin
    sender_name = 'Leandro Sardi'
    sender_email = 'support@connectionsphere.com'
    ret = client_postmark.create_sender(name: sender_name, from_email: sender_email)

    puts ret
    # => {:id=>4217384, :domain=>"connectionsphere.com", :email_address=>"support@connectionsphere.com", :reply_to_email_address=>"", :name=>"Leandro Sardi", :confirmed=>false, :spf_verified=>true, :spf_host=>"connectionsphere.com", :spf_text_value=>"v=spf1 a mx include:spf.mtasv.net ~all", :dkim_verified=>false, :weak_dkim=>false, :dkim_host=>"", :dkim_text_value=>"", :dkim_pending_host=>"20230212202906pm._domainkey.connectionsphere.com", :dkim_pending_text_value=>"k=rsa; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDg8qfeC7xRORq601VLvGLdzq0kx+XRqPmfatYd1o64iC4m43IV6xEkw9m2vuxGAPVNsH/rZsP6IOlll+k2SsLq1Tg/z0H5YLFtny9usyouEC1Bz9RS+eKFtuO3eel+1kdlNWBF5I/Upw0ZJ17iu8SnJpc5pbU17N/ut69G6IGWPwIDAQAB", :dkim_revoked_host=>"", :dkim_revoked_text_value=>"", :safe_to_remove_revoked_key_from_dns=>false, :dkim_update_status=>"Failed", :return_path_domain=>"", :return_path_domain_verified=>false, :return_path_domain_cname_value=>"pm.mtasv.net", :confirmation_personal_note=>""}
rescue => e
    puts e.message
end