module BlackStack
    module Emails
        class Schedule < Sequel::Model(:eml_schedule)
            many_to_one :user, :class=>:'BlackStack::MySaaS::User', :key=>:id_user
            many_to_one :campaign, :class=>:'BlackStack::Emails::Campaign', :key=>:id_campaign
            
            # - get the timezone of the account owner of this campaign.
            # - get the current datetime in the timezone of the account owner of this campaign, and store it in the variable `dt`.
            # - create array with all the days allowed in the schedule.
            # - create array with all the hours allowed in the schedule.
            # - return true if the day of the week of `dt` is in the array of days allowed, and if the hour of `dt` is in the array of hours allowed.
            def is_in_schedule?
                tz = self.campaign.user.account.timezone
                dt = tz.localtime
                self.days.include?(dt.wday) && self.hours.include?(dt.hour)
            end


            # return array of allowed days
            # 0 = sunday, 1 = monday, 2 = tuesday, 3 = wednesday, 4 = thursday, 5 = friday, 6 = saturday
            def days
                ret = []
                ret << 0 if self.schedule_day_0
                ret << 1 if self.schedule_day_1
                ret << 2 if self.schedule_day_2
                ret << 3 if self.schedule_day_3
                ret << 4 if self.schedule_day_4
                ret << 5 if self.schedule_day_5
                ret << 6 if self.schedule_day_6
                ret
            end

            # return array of allowed hours
            def hours
                ret = []
                ret << 0 if self.schedule_hour_0
                ret << 1 if self.schedule_hour_1
                ret << 2 if self.schedule_hour_2
                ret << 3 if self.schedule_hour_3
                ret << 4 if self.schedule_hour_4
                ret << 5 if self.schedule_hour_5
                ret << 6 if self.schedule_hour_6
                ret << 7 if self.schedule_hour_7
                ret << 8 if self.schedule_hour_8
                ret << 9 if self.schedule_hour_9
                ret << 10 if self.schedule_hour_10
                ret << 11 if self.schedule_hour_11
                ret << 12 if self.schedule_hour_12
                ret << 13 if self.schedule_hour_13
                ret << 14 if self.schedule_hour_14
                ret << 15 if self.schedule_hour_15
                ret << 16 if self.schedule_hour_16
                ret << 17 if self.schedule_hour_17
                ret << 18 if self.schedule_hour_18
                ret << 19 if self.schedule_hour_19
                ret << 20 if self.schedule_hour_20
                ret << 21 if self.schedule_hour_21
                ret << 22 if self.schedule_hour_22
                ret << 23 if self.schedule_hour_23
                ret
            end

        end # class Schedule
    end # Emails
end # BlackStack