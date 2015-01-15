module Forem
  class View
    include Mongoid::Document
    include Mongoid::Timestamps

    field :count, type: Integer, default: 0
    field :current_viewed_at
    field :past_viewed_at
    # embedded_in :topic, :class_name => 'Forem::Topic'
    before_create :set_viewed_at_to_now

    belongs_to :viewable, :polymorphic => true
    belongs_to :user, :class_name => Forem.user_class.to_s

    validates :viewable_id, :viewable_type, :presence => true
    attr_accessible :user, :current_viewed_at, :count

    def viewed_at
      updated_at
    end

    private
    def set_viewed_at_to_now
      self.current_viewed_at = Time.now
      self.past_viewed_at = current_viewed_at
    end
  end
end
