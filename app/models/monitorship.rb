class Monitorship < ActiveRecord::Base
    belongs_to :user
    belongs_to :topic

    validates_presence_of :user_id, :topic_id
    validate :uniqueness_of_relationship
    before_create :check_for_inactive

    attr_accessible :user_id, :topic_id

  protected
    def uniqueness_of_relationship
      already_exists = self.class.exists?(:user_id => user_id, :topic_id => topic_id, :active => true)
      if already_exists
        errors.add_to_base("Cannot add duplicate user/topic relation")
      end
      !already_exists
    end

    def check_for_inactive
      monitorship = self.class.find_by_user_id_and_topic_id_and_active(user_id, topic_id, false)
      if monitorship
        Monitorship.update_all('active = 1', :id => monitorship.id)
      end
      !monitorship
    end
end
