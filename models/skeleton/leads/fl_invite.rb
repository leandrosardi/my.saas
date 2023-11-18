# TODO: derecated in favor of https://github.com/leandrosardi/mysaas/issues/124
module BlackStack
module Leads
  class Invite < Sequel::Model(:fl_invite)
    many_to_one :user, :class=>:'BlackStack::MySaaS::User', :key=>:id_user
  end
end
end
