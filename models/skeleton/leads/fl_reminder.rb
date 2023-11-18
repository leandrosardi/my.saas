module BlackStack
  module Leads
    class Reminder < Sequel::Model(:fl_reminder)
      many_to_one :fl_lead, :class=>:'BlackStack::Leads::Lead', :key=>:id_lead
      many_to_one :fl_user, :class=>:'BlackStack::Leads::User', :key=>:id_user

      def to_hash
        {
          'id' => self.id,
          'id_lead' => self.id_lead,
          'id_user' => self.id_user,
          'create_time' => self.create_time,
          'delete_time' => self.delete_time,
          'deleted' => self.delete_time.nil? ? false : true,
          'expiration_time' => self.expiration_time,
          'done' => self.done,
          'description' => self.description,
        }
      end

    end # class Reminder
  end # module Leads
end # module BlackStack