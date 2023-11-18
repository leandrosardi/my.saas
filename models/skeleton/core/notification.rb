module BlackStack
    module MySaaS
      class Notification < Sequel::Model(:notification)
        many_to_one :user, :class=>:'BlackStack::MySaaS::User', :key=>:id_user
        # options
        attr_accessor :track_opens, :track_clicks
  
        # replace the merge-tag <CONTENT HERE> for the content of the email
        PIXEL_MERGE_TAG = '<!-- PIXEL_IMAGE_HERE -->'
        NOTIFICATION_CONTENT_MERGE_TAG = "<CONTENT HERE>"
        NOTIFICATION_BODY_TEMPLATE = "
          <!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">
          <html xmlns=\"http://www.w3.org/1999/xhtml\">
          <head>
          <meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />
          <title>Invitation</title>
          <style>
          body { font-family: Arial; } 
          a { text-decoration:none; } 
          a.bold { font-weight: bold; } 
          p { font-size:16px; } 
          //ddle;background-color:rgb(34,177,76);float:left;-webkit-border-radius:10px;-moz-border-radius:7px;border-radius:7px;padding-top:7px;padding-bottom:10px;padding-left:10px;padding-right:10px;font-size:14px;font-family:Arial;color:rgb(245,245,245);} 
          .medium-blue-button {text-align:center;vertical-align:middle;background-color:rgb(0,128,255);float:left;-webkit-border-radius:10px;-moz-border-radius:7px;border-radius:7px;padding-top:7px;padding-bottom:10px;padding-left:10px;padding-right:10px;font-size:14px;font-family:Arial;color:rgb(245,245,245);} 
          .container{width:100%}
          .row-fluid .span12{width:100%;*width:99.94252873563218%}
          .row-fluid .span11{width:91.37931034482759%;*width:91.32183908045977%}
          .row-fluid .span10{width:82.75862068965517%;*width:82.70114942528735%}
          .row-fluid .span9{width:74.13793103448276%;*width:74.08045977011494%}
          .row-fluid .span8{width:65.51724137931035%;*width:65.45977011494253%}
          .row-fluid .span7{width:56.896551724137936%;*width:56.83908045977012%}
          .row-fluid .span6{width:48.275862068965516%;*width:48.2183908045977%}
          .row-fluid .span5{width:39.6551724137931%;*width:39.59770114942529%}
          .row-fluid .span4{width:31.03448275862069%;*width:30.977011494252874%}
          .row-fluid .span3{width:22.413793103448278%;*width:22.35632183908046%}
          .row-fluid .span2{width:13.793103448275861%;*width:13.735632183908045%}
          .row-fluid .span1{width:5.172413793103448%;*width:5.114942528735632%}
          .big-green-button {text-align:center;vertical-align:middle;background-color:rgb(34,177,76);display:block;float:left;width:100%;-webkit-border-radius:10px;-moz-border-radius:10px;border-radius:10px;padding-top:20px;padding-bottom:20px;padding-left:20px;padding-right:20px;font-size:28px;font-family:Arial;color:rgb(245,245,245);}
          .widget-chat .message>img{display:block;float:left;height:40px;margin-bottom:-40px;width:40px;-webkit-border-radius:3px;-moz-border-radius:3px;border-radius:3px}
          .widget-chat .message>div{display:block;float:left;font-size:12px;margin-top:-3px;margin-bottom:15px;padding-left:55px;width:100%;-webkit-box-sizing:border-box;-moz-box-sizing:border-box;box-sizing:border-box}
          .widget-chat .message>div>div{background:rgba(0,0,0,0.04);font-size:13px;padding:7px 12px 9px 12px;-webkit-border-radius:3px;-moz-border-radius:3px;border-radius:3px}
          .widget-chat .message>div>div:before{border-bottom:6px solid transparent;border-right:6px solid rgba(0,0,0,0.04);border-top:6px solid transparent;content:\"\";display:block;height:0;margin:0 0 -12px -18px;position:relative;width:0}
          .widget-chat .message>div>span{color:#bbb}
          .widget-chat .message.right>div>div:before{border-left:6px solid rgba(0,0,0,0.04);border-right:0;float:right;left:18px;margin-left:0}
          .widget-chat .message.right>img{float:right}
          .widget-chat .message.right>div{padding-left:0;padding-right:55px}
          .widget-chat .widget-actions{border-top:1px solid rgba(0,0,0,0.08);margin-top:10px}
          .widget-chat form{margin:0}
          .widget-chat form>div{margin:-30px 100px 0 0}
          .widget-chat form>div textarea,
          .widget-chat form>div input[type=text]{display:block;width:100%}
          .widget-chat form .btn{display:inline-block;width:70px}.widget-messages .message{border-bottom:1px solid rgba(0,0,0,0.08);padding:5px 0;min-height:20px;*zoom:1}.widget-messages .message:before,.widget-messages .message:after{display:table;content:\"\";line-height:0}.widget-messages .message:after{clear:both}.widget-messages .message div,.widget-messages .message a{display:block;height:20px;float:left;position:relative;z-index:2}.widget-messages .message .date{color:#888;float:right;width:50px}.widget-messages .message .action-checkbox{width:20px;line-height:0;font-size:0}.widget-messages .message .from{width:115px;padding-left:5px;overflow:hidden;color:#444}.widget-messages .message .title{display:block!important;height:auto;min-height:20px;white-space:normal;z-index:1;width:100%;margin-top:-20px;padding:0 55px 0 145px;-webkit-box-sizing:border-box;-moz-box-sizing:border-box;box-sizing:border-box}.widget-messages .message.unread .title{font-weight:600}.box.widget-messages .message,.box .widget-messages .message{margin:0 -20px;padding-left:20px;padding-right:20px}.widget-status-panel{*zoom:1}.widget-status-panel:before,.widget-status-panel:after{display:table;content:\"\";line-height:0}.widget-status-panel:after{clear:both}.widget-status-panel .status{border-right:1px solid rgba(0,0,0,0.12);text-align:center}.widget-status-panel .status:last-child{border-right:0}.widget-status-panel .status>a{color:#444;display:block;line-height:12px;height:12px;margin:10px 0 -22px 0;position:relative;width:30px;-webkit-box-sizing:border-box;-moz-box-sizing:border-box;box-sizing:border-box;opacity:.15;filter:alpha(opacity=15);-webkit-transition:all .2s;-moz-transition:all .2s;-o-transition:all .2s;transition:all .2s}.widget-status-panel .status>a:hover{text-decoration:none;opacity:.6;filter:alpha(opacity=60)}.widget-status-panel .status .value,.widget-status-panel .status .caption{width:100%}.widget-status-panel .status .value{color:#888;font-size:31px;height:100px;line-height:100px}.widget-status-panel .status .caption{border-top:1px solid rgba(0,0,0,0.12);color:#666;font-size:12px;height:30px;line-height:30px;text-transform:uppercase;-webkit-box-shadow:rgba(255,255,255,0.75) 0 1px 0 inset;-moz-box-shadow:rgba(255,255,255,0.75) 0 1px 0 inset;box-shadow:rgba(255,255,255,0.75) 0 1px 0 inset}.widget-status-panel.light{background:0;border:1px solid rgba(0,0,0,0.12);-webkit-box-shadow:rgba(255,255,255,0.75) 0 1px 0,rgba(255,255,255,0.75) 0 1px 0 inset;-moz-box-shadow:rgba(255,255,255,0.75) 0 1px 0,rgba(255,255,255,0.75) 0 1px 0 inset;box-shadow:rgba(255,255,255,0.75) 0 1px 0,rgba(255,255,255,0.75) 0 1px 0 inset}@media(max-width:767px){.widget-status-panel .status{border-bottom:1px solid rgba(0,0,0,0.12);border-right:none!important;-webkit-box-shadow:rgba(255,255,255,0.75) 0 1px 0;-moz-box-shadow:rgba(255,255,255,0.75) 0 1px 0;box-shadow:rgba(255,255,255,0.75) 0 1px 0}.widget-status-panel .status:last-child{border-bottom:0;-webkit-box-shadow:none;-moz-box-shadow:none;box-shadow:none}}.widget-stars-rating,.widget-stars-rating li{padding:0;margin:0;list-style:none;display:inline-block}.widget-stars-rating a,.widget-stars-rating li a{display:block;color:#bbb;text-decoration:none;text-align:center;font-size:15px}.widget-stars-rating .active a{color:#3690e6}.widget-stream .stream-empty{color:#ccc;font-size:16px;font-weight:600;font-style:italic;text-align:center}.widget-stream .stream-event{border-bottom:1px solid rgba(0,0,0,0.08);min-height:34px;padding:15px 0;opacity:0;filter:alpha(opacity=0)}.widget-stream .stream-event:last-child{border-bottom:0;padding-bottom:0}.widget-stream .stream-icon{border-radius:3px;display:block;font-size:17px;line-height:34px;height:34px;margin-bottom:-34px;text-align:center;width:34px}.widget-stream .stream-time{color:#888;display:block;float:right;font-size:12px;line-height:15px;height:15px}.widget-stream .stream-message,.widget-stream .stream-caption{display:block;margin-left:46px;margin-right:50px}.widget-stream .stream-caption{font-size:12px;font-weight:600;line-height:15px;text-transform:uppercase}.box .widget-stream{margin:0 -20px}.box .widget-stream .stream-event{padding-left:20px;padding-right:20px}.widget-maps img{max-width:none!important}.widget-maps label{display:inline!important;width:auto!important}.widget-maps .gmnoprint{line-height:normal!important}.com{color:#93a1a1}.lit{color:#195f91}.pun,.opn,.clo{color:#93a1a1}.fun{color:#dc322f}.str,.atv{color:#D14}.kwd,.prettyprint .tag{color:#1e347b}.typ,.atn,.dec,.var{color:teal}.pln{color:#48484c}.prettyprint{padding:8px;background-color:#f7f7f9;border:1px solid #e1e1e8}.prettyprint.linenums{-webkit-box-shadow:inset 40px 0 0 #fbfbfc,inset 41px 0 0 #ececf0;-moz-box-shadow:inset 40px 0 0 #fbfbfc,inset 41px 0 0 #ececf0;box-shadow:inset 40px 0 0 #fbfbfc,inset 41px 0 0 #ececf0}ol.linenums{margin:0 0 0 33px}ol.linenums li{padding-left:12px;color:#bebec5;line-height:20px;text-shadow:0 1px 0 #fff}
          </style>
          </head>
          <body style=\"background-color:rgb(225,225,225);width:100%\" width=\"100%\">
          <section class=\"container\">
          <table style=background-color:rgb(255,255,255);width:75%;align:center;horizontal-align:center;padding:20px; align=center>
          <!--logo--> 
          <tr><td align=left style='text-align:left;'><img src='#{BlackStack::Notifications::logo_url}' height='64px' /></td></tr> 
          <tr>
          <td>
          #{NOTIFICATION_CONTENT_MERGE_TAG}
          </td>
          <tr>
          <tr><td height=5px><br/></td></tr>
          <!--signature--> 
          <tr><td><p style='font-size:18px;'>Warmest Regards.</p></td></tr>
          <tr><td><img src=#{BlackStack::Notifications::signature_picture_url} width='128px' height='128px' style='border-radius: 64px; height: auto; max-width: 100%;' /></td></tr> 
          <tr><td><p style='font-size:18px;'><b>#{BlackStack::Notifications::signature_name}</b>,<br/>#{BlackStack::Notifications::signature_position}, <a href='#{CS_HOME_WEBSITE}'>#{COMPANY_NAME}</a>.</p></td></tr>
          </table>  
          </section>
          #{PIXEL_MERGE_TAG}
          </body>
          </html>
        "

        def initialize(i_user, options={})
          super()
          self.id_user = i_user.id
          self.type = 0
          # if options has key :track_opens, map its value to self.track_opens.
          # otherwise, set self.track_opens to true.
          self.track_opens = options[:track_opens] if options.has_key?(:track_opens)
          self.track_opens = true if self.track_opens.nil? 
          # if options has key :track_clicks, map its value to self.track_clicks.
          # otherwise, set self.track_clicks to true.
          self.track_clicks = options[:track_clicks] if options.has_key?(:track_clicks)
          self.track_clicks = true if self.track_clicks.nil? 
        end

        # return how many minutes ago was the email sent.
        # if `delivery_time` is nil, then return nil.
        def oldness
          return nil if self.delivery_time.nil?
          q = "SELECT EXTRACT(MINUTES FROM n.delivery_time-current_timestamp()) AS \"old\" FROM notification n WHERE n.id='#{self.id}'"
          -DB[q].first[:old].to_i 
        end

        def subject_template
          "Hello World Subject!"
        end

        def body_template
          "Hello World Body!"
        end

        def delivery
          BlackStack::Emails::delivery(
            :receiver_name => self.user.name,
            :receiver_email => self.user.email,
            :subject => self.subject,
            :body => self.body,
          )
        end # def delivery
        
        # return the url of the pixel for open tracking
        def pixel_url
          errors = []
          # validation: self.id is not nil and it is a valid guid
          errors << "id is nil" if self.id.nil? || !self.id.guid?
          # validation: self.id_user is not nil and it is a valid guid
          errors << "id_user is nil" if self.id_user.nil? || !self.id_user.guid?
          # if any error happened, raise an exception
          raise errors.join(", ") if errors.size > 0
          # return
          "#{BlackStack::Emails.tracking_url}/api1.0/notifications/open.json?nid=#{self.id.to_guid}"
        end

        def do
          return if !BlackStack::Emails.is_configured?

          # save the email to the database
          self.id = guid
          self.create_time = now
          #self.type = i_type # this has been defined in the constructor
          #self.id_user = self.user.id # this has been defined in the constructor
          self.name_to = self.user.name
          self.email_to = self.user.email
          self.subject = self.subject_template
          self.body = NOTIFICATION_BODY_TEMPLATE.gsub(/#{NOTIFICATION_CONTENT_MERGE_TAG}/, self.body_template)
          self.name_from = BlackStack::Emails::from_name
          self.email_from = BlackStack::Emails::from_email
          self.save

          # replace all links by tracking links
          if self.track_clicks
            # number of URL
            n = 0
            # iterate all href attributes of anchor tags
            # reference: https://stackoverflow.com/questions/53766997/replacing-links-in-the-content-with-processed-links-in-rails-using-nokogiri
            fragment = Nokogiri::HTML.fragment(self.body)
            fragment.css("a[href]").each do |link| 
              # increment the URL counter
              n += 1
              # create and save the object BlackStack::MySaaS::NotificationLink
              o = BlackStack::MySaaS::NotificationLink.new
              o.id = guid
              o.id_notification = self.id
              o.create_time = now
              o.link_number = n
              o.url = link['href']
              o.save
              # replace the url by the tracking url
              link['href'] = o.tracking_url
            end
            # update notification body
            self.body = fragment.to_html
            # update changes
            self.save
          end # if self.track_clicks

          # apply the pixel for open tracking
          if self.track_opens
            self.body = self.body.gsub(/#{Regexp.escape(PIXEL_MERGE_TAG)}/, "<img src='#{self.pixel_url}' height='1px' width='1px' />")
            # update changes
            self.save
          end

          # delivery the email
          self.delivery

          # update the email status
          self.delivery_time = now
          self.save
        end
        
      end # class Notification
    end # module MySaaS
  end # module BlackStack