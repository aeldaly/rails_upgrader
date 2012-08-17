class CriticRatio < ActiveRecord::Base
 
  attr_accessor :my_rating

  DEFAULT_RATIO_FOR_SELF = 5
  DEFAULT_RATIO_FOR_OTHERS = 5

  belongs_to :person
  belongs_to :critic, :class_name => 'Person', :counter_cache => :subscribers_count

  before_save :cache_current_ratio

  before_validation_on_create    :before_validation_on_create
  before_validation_on_create   :before_validation_on_create
  after_create :create_notification
  before_destroy :destroy_activity_reports
  after_validation_on_create :after_validation_on_create
  after_validation_on_update :after_validation_on_update

  validates_presence_of :person_id, :critic_id
  validates_uniqueness_of :person_id, :scope => [:critic_id]

  validate_on_create :check_tos, :validate_promotion_code

  scope :critic, lambda {|critic|
   {:conditions => {:critic_id => critic.id}}
  }

  scope :person, lambda {|person|
   {:conditions => {:person_id => person.id}}
  }

  def ratio
   current_ratio
  end

  def cache_current_ratio
   return unless current_ratio_changed?
   self.previous_ratio = current_ratio_was
  end
  before_validation_on_update :before_validation_on_update
  def can_edit?
   self.person.subscribed? || self.paid? || self.person_id == self.critic_id || (self.free_until && self.free_until >= Time.now.to_date)
  end

  def set_free_until(date = 3.months.from_now) #don't think this is used anymore.  2008.12.08
   self.free_until = date
  end

  def set_ratio(ratio)
   set_ratio!(ratio)
  end

  def set_ratio!(ratio)
   self.current_ratio = ratio
   self.save!
  end

  before_validation_on_create :geocode_address, :set_default_wine_preferences

  private

    def destroy_activity_reports
      return unless person && critic
      Activity.delete_all("action = 'follow' AND person_id = #{person.id} AND first_item_id = #{critic.id}")
    end

    def create_notification
      return if critic.critic? or critic == person
      Activity.report(person, 'follow', critic)
    end

    def set_current_ratio
      if self.critic == self.person
        self.current_ratio = CriticRatio::DEFAULT_RATIO_FOR_SELF
      else
        self.current_ratio = CriticRatio::DEFAULT_RATIO_FOR_OTHERS if self.critic
      end
    end
 
end